
function Get-ModuleItem {

    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations containing Module Source
        [Parameter(
            Mandatory,
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
        foreach ($p in $Path) {
            Write-Debug "  Looking for module source in '$p'"
            try {
                $item = Get-Item $p -ErrorAction Stop
                if ($item -isnot [System.IO.DirectoryInfo]) {
                    Write-Verbose "$p is not a Directory, skipping"
                    continue
                }
                foreach ($mod_path in ($item | Get-ChildItem -Directory)) {
                    $info = @{}
                    [ModuleFlag]$flags = [ModuleFlag]::None

                    $name = $mod_path.Name
                    Write-Debug "  Module name is $name"
                    $info['Name'] = $name

                    $man_file = (Join-Path $mod_path "$name.psd1")
                    if (Test-Path $man_file) {
                        $man = Import-Psd $man_file
                        if (($man.Keys -contains 'PrivateData') -and
                            ($man.Keys -contains 'GUID')) {

                                [ModuleFlag]$flags = [ModuleFlag]::HasManifest
                                Write-Debug "  Found $name.psd1 testing Manifest"
                                $info['ManifestFile'] = "$name.psd1"
                            }
                    }

                    $source_info = Get-SourceItem $mod_path.Parent | Where-Object Module -like $name
                    if ($null -ne $source_info) {
                        [ModuleFlag]$flags += [ModuleFlag]::HasModule
                    }

                    if ($flags.hasFlag([ModuleFlag]::HasManifest)) {
                        Write-Verbose "Manifest found in $($mod_path.BaseName)"
                        foreach ($key in $man.Keys) {
                            if ($key -notlike 'PrivateData') {
                                $info[$key] = $man[$key]
                            }
                        }
                        foreach ($key in $man.PrivateData.PSData.Keys) {
                            $info[$key] = $man.PrivateData.PSData[$key]
                        }
                    }
                    if ($flags.hasFlag([ModuleFlag]::HasModule)) {
                        $info['SourceDirectories'] = $source_info |
                            Where-Object { @('function', 'class', 'enum') -contains $_.Type } |
                                Select-Object -ExpandProperty Directory | Sort-Object -Unique
                        $info['SourceInfo'] = $source_info
                        if ($info.Keys -notcontains 'RootModule') {
                            $info['ModuleFile'] = "$name.psm1"
                        } else {
                            $info['ModuleFile'] = $info.RootModule
                        }
                        Write-Verbose "Module source found in $($mod_path.BaseName)"
                    }
                    if ($AsHashTable) {
                        $info | Write-Output
                    } else {
                        $info['PSTypeName'] = 'Stitch.ModuleItem'
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
