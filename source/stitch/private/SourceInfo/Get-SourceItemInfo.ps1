
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
        @(
            @{
                Option      = 'Constant'
                Name        = 'POWERSHELL_FILETYPES'
                Value       = @( '.ps1', '.psm1' )
                Description = 'Files that are Parsable into an AST'
            }
            @{
                Option      = 'Constant'
                Name        = 'DATA_FILETYPES'
                Value       = @( '.psd1' )
                Description = 'PowerShell Data files'
            }
        ) | ForEach-Object { New-Variable @_ }

        try {
            if ($PSBoundParameters.ContainsKey('TypeMap')) {
                $map = Get-SourceTypeMap -Path $TypeMap
            } else {
                # try to load defaults
                $map = Get-SourceTypeMap
            }
        } catch {
            #TODO: It would be better to have a minimal source map to fall back to
            throw "Could not find map for source types`n$_"
        }
    }
    process {
        :path foreach ($p in $Path) {
            Write-Debug "Processing $p"

            #-------------------------------------------------------------------------------
            #region Load file

            try {
                $fileItem = Get-Item $p -ErrorAction Stop
                $itemProperties = $fileItem.psobject.Properties | Select-Object -ExpandProperty Name

            } catch {
                Write-Error "Could not read $p`n$_"
                continue path
            }

            #endregion Load file
            #-------------------------------------------------------------------------------
            #-------------------------------------------------------------------------------
            #region Create sourceItem object
            $sourceObject = @{
                PSTypeName  = 'Stitch.SourceItemInfo'
                Path        = $fileItem.FullName
                BaseName    = $fileItem.BaseName
                FileName    = $fileItem.Name
                Name        = $fileItem.BaseName
                FileType    = ''
                Ast         = ''
                Tokens      = @()
                ParseErrors = @()
                Directory   = ''
                Module      = ''
                Type        = ''
                Component   = ''
                Visibility  = ''
                Verb        = ''
                Noun        = ''
            }

            #endregion Create sourceItem object
            #-------------------------------------------------------------------------------


            #-------------------------------------------------------------------------------
            #region File types
            # Any pattern listed in the FileTypes key will be considered a SourceItem

            $fileTypes = $map.FileTypes
            :filemap foreach ($fileMap in $fileTypes.GetEnumerator()) {
                $pattern = $fileMap.Key
                $properties = $fileMap.Value
                if ($fileItem.Name -match $pattern) {
                    foreach ($property in $properties.GetEnumerator()) {
                        $sourceObject[$property.Key] = $property.Value
                    }
                }
            }

            $sourceObject.FileType = $fileType ?? 'Source File'
            #endregion File types
            #-------------------------------------------------------------------------------

            #-------------------------------------------------------------------------------
            #region Parse file

            # The filetypes listed in POWERSHELL_FILETYPES are the extensions that are able to
            # be parsed into an AST
            #TODO: Move these into a key in sourcetype config
            if ($POWERSHELL_FILETYPES -contains $fileItem.Extension) {
                try {
                    Write-Debug '  - Parsing powershell'
                    $tokens = @()
                    $parseErrors = @()
                    $ast = [Parser]::ParseFile($fileItem.FullName, [ref]$tokens, [ref]$parseErrors)
                    if ($null -ne $ast) {
                        $sourceObject.Ast = $ast
                        $sourceObject.Tokens = $tokens
                        $sourceObject.ParseErrors = $parseErrors
                    }

                } catch {
                    Write-Warning "Could not parse source item $($fileItem.FullName)`n$_"
                }
                # The filetypes listed in DATA_FILETYPES are able to be imported into the 'Data' field
                # currently, only psd1 files are listed
            } elseif ($DATA_FILETYPES -contains $fileItem.Extension) {
                switch -Regex ($fileItem.Extension) {
                    '^\.psd1$' {
                        try {
                            $sourceObject['Data'] = Import-Psd $fileItem.FullName -Unsafe
                        } catch {
                            Write-Warning "Could not import data from $($fileItem.FullName)`n$_"
                        }
                    }
                }
            }

            #endregion Parse file
            #-------------------------------------------------------------------------------

            #-------------------------------------------------------------------------------
            #region Root directory

            if ([string]::IsNullorEmpty($Root)) {
                Write-Debug '  - No Root path given.  Attempting to resolve from project root'
                $projectRoot = Resolve-ProjectRoot
                if ($null -eq $projectRoot) {
                    Write-Verbose '    - Could not resolve the Project Root'
                    $possibleBuildRoot = $PSCmdlet.GetVariableValue('BuildRoot')
                    if ($null -ne $possibleBuildRoot) {
                        Write-Debug '     - Using BuildRoot as root'
                        $projectRoot = $possibleBuildRoot
                    } else {
                        Write-Debug '     - Using current location as root'
                        $projectRoot = Get-Location
                    }
                    Write-Verbose "    - Project root is : $projectRoot"
                }
                $relativeToProject = [System.IO.Path]::GetRelativePath($projectRoot, $fileItem.FullName)
                $projectPathParts = $relativeToProject -split [regex]::Escape([System.IO.Path]::DirectorySeparatorChar)
                $rootName = $projectPathParts[0]
                Write-Debug "    - Guessing $rootName is the Source directory"
                $Root = (Join-Path $projectRoot $rootName)
                Write-Verbose "  - Setting Root to $Root"

            }
            if ([string]::IsNullorEmpty($Root)) {
                throw 'Could not determine the Root directory for SourceItems'
            }

            #endregion Root directory
            #-------------------------------------------------------------------------------

            #-------------------------------------------------------------------------------
            #region Match path
            Write-Debug "Getting relative path from root '$Root'"
            $adjustedPath = [System.IO.Path]::GetRelativePath($Root, $fileItem.FullName)
            Write-Debug "  - '$($fileItem.FullName)' adjusted path is '$adjustedPath'"
            $sourceObject['ProjectPath'] = $adjustedPath

            $pathItems = [System.Collections.ArrayList]@(
                $adjustedPath -split [regex]::Escape([System.IO.Path]::DirectorySeparatorChar)
            )

            Write-Debug "Path Items for ${adjustedPath}: $($pathItems -join ', ')"

            Write-Debug "Matching 'Path' settings in Source Types Configuration"


            #! levels is an Array of hashes
            $levels = $map.Path
            :level foreach ($level in $levels) {
                #-------------------------------------------------------------------------------
                #region depth check

                $pathItemIndex = $levels.IndexOf($level)
                #! There are more levels configured than there are level in this sourceItem.
                #! break out of the level loop
                if ($pathItemsIndex -ge $pathItems.Count) {
                    Write-Debug "  - Index is $pathItemsIndex. No more path items"
                    break level
                }
                #endregion depth check
                #-------------------------------------------------------------------------------

                #-------------------------------------------------------------------------------
                #region Path level

                # pathField is the current component of the path when it was split, and level is the hashtable
                # from the sourcetype map config
                $pathField = $pathItems[$pathItemIndex]

                # The user has the option of setting the pathField to a property of the sourceObject by
                # adding an entry in the $levels Array as a string
                # or using a regex to set values by adding a hashtable with the regex as the key and a hashtable of
                # sourceObject property => value
                if ($level -is [String]) {
                    Write-Debug "  - level $pathItemIndex is $level"
                    $sourceObject[$level] = $pathField
                    Write-Debug "    - $level  => $pathField"
                    continue level
                } elseif ($level -is [hashtable]) {
                    Write-Debug "  - level $pathItemIndex is a hashtable"
                    foreach ($levelMap in $level.GetEnumerator()) {
                        $pattern = $levelMap.Key
                        $properties = $levelMap.Value
                        Write-Debug "    - testing if $pathField matches $pattern"
                        if ($pathField -match $pattern) {
                            # Save the matches so we can use them when we match on the values below
                            $pathFieldMatches = $Matches
                            foreach ($property in $properties.GetEnumerator()) {
                                #! if the value has `{<num>}` then use that match group as the value
                                if ($property.Value -match '\{(\d+)\}') {
                                    $matchNumber = [int]$Matches.1
                                    Write-Debug "    - Match number: $($property.Key) => $($pathFieldMatches[$matchNumber])"
                                    if (-not ([string]::IsNullorEmpty($pathFieldMatches[$matchNumber]))) {
                                        $sourceObject[$property.Key] = $pathFieldMatches[$matchNumber]
                                    }
                                    #! if the value has `{<word>}` then use that match group as the value
                                } elseif ($property.Value -match '\{(\w+)\}') {
                                    $matchWord = $Matches.1
                                    if (-not ([string]::IsNullorEmpty($pathFieldMatches[$matchWord]))) {
                                        Write-Debug "    - Match word: $($property.Key) => $($pathFieldMatches[$matchWord])"
                                        $sourceObject[$property.Key] = $pathFieldMatches[$matchWord]
                                    }
                                } else {
                                    $sourceObject[$property.Key] = $property.Value
                                }
                            }
                        }
                    }
                    continue level
                }
            }
            #endregion Path level
            #-------------------------------------------------------------------------------            }

            #endregion Match path
            #-------------------------------------------------------------------------------


            $mapProperties = $map.Keys

            foreach ($mapProperty in $mapProperties) {
                # if the key maps to a property of the fileItem
                if ($itemProperties -contains $mapProperty) {
                    # The fileItem field we are going to compare against
                    $field = $mapProperty

                    Write-Debug "Matching $field settings in sourcetypes"
                    foreach ($fieldMap in $map[$field].GetEnumerator()) {
                        $pattern = $fieldMap.Key
                        $properties = $fieldMap.Value
                        if ($fileItem.($field) -match $pattern) {
                            Write-Debug "  - $($fileItem.($field)) matches $pattern"
                            #! Store these matches in $fieldMatches so that we don't lose them when we do
                            #! additional matches below
                            $fieldMatches = $Matches
                            foreach ($matchMap in $properties.GetEnumerator()) {
                                Write-Debug "  - $field map $($matchMap.Key) => $($matchMap.Value)"
                                #! if the value has `{<num>}` then use that match group as the value
                                if ($matchMap.Value -match '\{(\d+)\}') {
                                    $matchNumber = [int]$Matches.1
                                    Write-Debug "    - Match number: $($matchMap.Key) => $($fieldMatches[$matchNumber])"
                                    if (-not ([string]::IsNullorEmpty($fieldMatches[$matchNumber]))) {
                                        $sourceObject[$matchMap.Key] = $fieldMatches[$matchNumber]
                                    }
                                    #! if the value has `{<word>}` then use that match group as the value
                                } elseif ($matchMap.Value -match '\{(\w+)\}') {
                                    $matchWord = $Matches.1
                                    if (-not ([string]::IsNullorEmpty($fieldMatches[$matchWord]))) {
                                        Write-Debug "    - Match word: $($matchMap.Key) => $($fieldMatches[$matchWord])"
                                        $sourceObject[$matchMap.Key] = $fieldMatches[$matchWord]
                                    }
                                } else {
                                    Write-Debug "    - $($matchMap.Key) => $($matchMap.Value)"
                                    $sourceObject[$matchMap.Key] = $matchMap.Value
                                }
                            }
                        }
                    }
                }
            }
            #! special case: Manifest file
            if ($fileItem.Extension -like '.psd1') {
                #! this is why this one is special.  A GUID field means that it is probably a manifest
                #TODO: Add the ability to "lookup" a field from a definition in the map config
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
