
using namespace System.Management.Automation.Language

function Get-SourceItemInfo {
    [CmdletBinding()]
    param(
        # The directory to look in for source files
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        # The root directory of the source item, using the convention of a
        # source folder with one or more module folders in it.
        # Should be the Module's Source folder of your project
        [Parameter(
            Position = 0
        )]
        [string]$Root,

        # Path to the source type map
        [Parameter(
        )]
        [string]$TypeMap

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $POWERSHELL_FILETYPES = @(
            '.ps1',
            '.psm1'
        )
        $DATA_FILETYPES = @(
            '.psd1'
        )
        try {
            if ($PSBoundParameters.ContainsKey('TypeMap')) {
                $map = Get-SourceTypeMap -Path $TypeMap
            } else {
                # try to load defaults
                $map = Get-SourceTypeMap
            }
        }
        catch {
            throw "Could not find map for source types`n$_"
        }
    }
    process {
        foreach ($p in $Path) {
            Write-Debug "Processing $p"

            $fileTypes = $map.FileTypes
            try {
                $fileItem = Get-Item $p -ErrorAction Stop
            } catch {
                throw "Could not read $p`n$_"
            }
            if ($fileTypes.Keys -contains $fileItem.Extension) {
                $fileType = $fileTypes[$fileItem.Extension]
                Write-Debug "  - $($file.Name) is a $fileType item"
            } else {
                Write-Verbose "Not adding $($fileItem.Name) because it is a $($fileItem.Extension) file"
                continue
            }
            $sourceObject = @{
                PSTypeName   = 'Stitch.SourceItemInfo'
                Path         = $fileItem.FullName
                BaseName     = $fileItem.BaseName
                FileName     = $fileItem.Name
                Name         = $fileItem.BaseName
                FileType     = $fileType
                Ast          = ''
                Directory    = ''
                Module       = ''
                Type         = ''
                Component    = ''
                Visibility   = ''
                Verb         = ''
                Noun         = ''
            }


            if ($POWERSHELL_FILETYPES -contains $fileItem.Extension) {
                try {
                    Write-Debug "  - Parsing powershell"
                    $ast = [Parser]::ParseFile($fileItem.FullName, [ref]$null, [ref]$null)
                    if ($null -ne $ast) {
                        $sourceObject.Ast = $ast
                    }
                }
                catch {
                    Write-Warning "Could not parse source item $($fileItem.FullName)`n$_"
                }
            } elseif ($DATA_FILETYPES -contains $fileItem.Extension) {
                switch -Regex ($fileItem.Extension) {
                    '^\.psd1$' {

                        try {
                            $sourceObject['Data'] = Import-Psd $fileItem.FullName -Unsafe
                        }
                        catch {
                            Write-Warning "Could not import data from $($fileItem.FullName)`n$_"
                        }
                    }
                }
            }


            if ([string]::IsNullorEmpty($Root)) {
                Write-Debug "  - No Root path given.  Attempting to resolve from project root"
                $projectRoot = Resolve-ProjectRoot
                Write-Debug "    - Project root is : $projectRoot"
                $relativeToProject = [System.IO.Path]::GetRelativePath($projectRoot, $fileItem.FullName)
                $projectPathParts = $relativeToProject -split [regex]::Escape([System.IO.Path]::DirectorySeparatorChar)
                $rootName = $projectPathParts[0]
                Write-Debug "    - Guessing $rootName is the Source directory"
                $Root = (Join-Path $projectRoot $rootName)
                Write-Debug "  - Setting Root to $Root"

            }

            if ([string]::IsNullorEmpty($Root)) {
                throw "Could not determine the Root directory for SourceItems"
            }

            Write-Debug "Getting relative path from root '$Root'"
            $adjustedPath = [System.IO.Path]::GetRelativePath($Root, $fileItem.FullName)
            Write-Debug "  - '$($fileItem.FullName)' adjusted path is '$adjustedPath'"
            $sourceObject['ProjectPath'] = $adjustedPath

            $pathItems = [System.Collections.ArrayList]@(
                $adjustedPath -split [regex]::Escape([System.IO.Path]::DirectorySeparatorChar)
            )

            Write-Debug "Matching Path settings in sourcetypes"
            $levels = $map.Path
            :level foreach ($level in $levels) {
                $pathItemIndex = $levels.IndexOf($level)
                if ($pathItemsIndex -ge $pathItems.Count) {
                    Write-Debug "  - Index is $pathItemsIndex. No more path items"
                    break level
                }
                $pathField = $pathItems[$pathItemIndex]
                if ($level -is [String]) {
                    Write-Debug "  - level $pathItemIndex is $level"
                    $sourceObject[$level] = $pathField
                    Write-Debug "    - $level  => $pathField"
                    continue level
                } elseif ($level -is [hashtable]) {
                    Write-Debug "  - level $pathItemIndex is a hashtable"
                    foreach ($pattern in $level.Keys) {
                        Write-Debug "    - testing if $pathField matches $pattern"
                        if ($pathField -match $pattern) {
                            foreach ($field in ($level[$pattern]).Keys) {
                                $sourceObject[$field] = $level[$pattern][$field]
                            }
                        }
                    }
                    continue level
                }
            }

            Write-Debug "Matching Name settings in sourcetypes"
            foreach ($namePattern in $map.Name.Keys) {
                if ($fileItem.Name -match $namePattern) {
                    Write-Debug "  - $($fileItem.Name) matches $namePattern"
                    $nameMaps = $map.Name[$namePattern]
                    $nameMatches = $Matches
                    foreach ($nameMap in $nameMaps.GetEnumerator()) {
                        Write-Debug "  - Name map $($nameMap.Name) => $($nameMap.Value)"
                        if ($nameMap.Value -match '^Matches\.(\d+)') {
                            $matchNumber = [int]$Matches.1
                            Write-Debug "    - Match number: $($nameMap.Name) => $($nameMatches[$matchNumber])"
                            $sourceObject[$nameMap.Name] = $nameMatches[$matchNumber]
                        } elseif ($nameMap.Value -match '^Matches\.(\w+)') {
                            $matchWord = $Matches.1
                            Write-Debug "    - Match word: $($nameMap.Name) => $($nameMatches[$matchWord])"
                            $sourceObject[$nameMap.Name] = $nameMatches[$matchWord]
                        } else {
                            Write-Debug "    - $($nameMap.Name) => $($nameMap.Value)"
                            $sourceObject[$nameMap.Name] = $nameMap.Value
                        }
                    }
                }
            }

            #! special case: Manifest file
            if ($fileItem.Extension -like '.psd1') {
                if ($sourceObject.Data.ContainsKey('GUID')) {
                    $sourceObject['FileType'] = 'PowerShell Module Manifest'
                    $sourceObject['Type'] = 'manifest'
                    $sourceObject['Visibility'] = 'public'
                }
            }
            [PSCustomObject]$sourceObject | Write-Output
        } # end foreach
    } # end process block
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
