
function Get-ModuleItem {
    <#
    .SYNOPSIS
        Retrieve the modules in the given path
    .DESCRIPTION
        Get-ModuleItem returns an object representing the information about the modules in the directory given in
        Path. It returns information from the manifest such as version number, etc. as well as SourceItemInfo
        objects for all of the source items found in it's subdirectories
    .EXAMPLE
        Get-ModuleItem .\source
    .LINK
        Get-SourceItem
    #>
    [OutputType('Stitch.ModuleItemInfo')]
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations containing Module Source
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        # Optionally return a hashtable instead of an object
        [Parameter(
        )]
        [switch]$AsHashTable
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('Path'))) {
            $Path = Find-SourceDirectory
        }
        foreach ($p in $Path) {
            Write-Debug "  Looking for module source in '$p'"
            try {
                $pathItem = Get-Item $p -ErrorAction Stop
                if (-not($pathItem.PSIsContainer)) {
                    Write-Verbose "$p is not a Directory, skipping"
                    continue
                }
                foreach ($modulePath in ($pathItem | Get-ChildItem -Directory)) {
                    $info = @{}
                    [ModuleFlag]$flags = [ModuleFlag]::None

                    $name = $modulePath.Name
                    Write-Debug "  Module name is $name"
                    $info['Name'] = $name
                    $info['ModuleName'] = $name

                    $manifestFile = (Join-Path $modulePath "$name.psd1")
                    if (Test-Path $manifestFile) {
                        $manifestObject = Import-Psd $manifestFile
                        if (($manifestObject.Keys -contains 'PrivateData') -and
                            ($manifestObject.Keys -contains 'GUID')) {

                                [ModuleFlag]$flags = [ModuleFlag]::HasManifest
                                Write-Debug "  Found $name.psd1 testing Manifest"
                                $info['ManifestFile'] = "$name.psd1"
                            }
                    }

                    $sourceInfo = Get-SourceItem $modulePath.Parent | Where-Object Module -like $name
                    if ($null -ne $sourceInfo) {
                        [ModuleFlag]$flags += [ModuleFlag]::HasModule
                    }

                    if ($flags.hasFlag([ModuleFlag]::HasManifest)) {
                        Write-Verbose "Manifest found in $($modulePath.BaseName)"
                        foreach ($key in $manifestObject.Keys) {
                            if ($key -notlike 'PrivateData') {
                                $info[$key] = $manifestObject[$key]
                            }
                        }
                        foreach ($key in $manifestObject.PrivateData.PSData.Keys) {
                            $info[$key] = $manifestObject.PrivateData.PSData[$key]
                        }
                    }
                    if ($flags.hasFlag([ModuleFlag]::HasModule)) {
                        $info['SourceDirectories'] = $sourceInfo |
                            Where-Object { @('function', 'class', 'enum') -contains $_.Type } |
                                Select-Object -ExpandProperty Directory | Sort-Object -Unique
                        $info['SourceInfo'] = $sourceInfo
                        if ($info.Keys -notcontains 'RootModule') {
                            $info['ModuleFile'] = "$name.psm1"
                        } else {
                            $info['ModuleFile'] = $info.RootModule
                        }
                        Write-Verbose "Module source found in $($modulePath.BaseName)"
                    }
                    if ($AsHashTable) {
                        $info | Write-Output
                    } else {
                        $info['PSTypeName'] = 'Stitch.ModuleItemInfo'
                        [PSCustomObject]$info | Write-Output
                    }
                }
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
