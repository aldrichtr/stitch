param(
    [Parameter()]
    [string]$ManifestBackupPath = (
        Get-BuildProperty ManifestBackupPath (Join-Path $Artifact 'backup')
    )
)
<#
.SYNOPSIS
    Create a copy of the manifest
#>
task backup.manifest {
    if (Test-Path $ManifestBackupPath) {
        logWarn "$ManifestBackupPath needs to be created"
        New-Item -Path $ManifestBackupPath -ItemType Directory -Force
    }

     $BuildInfo | Foreach-Module {
        $config = $_
        $last_version = [System.Version]($config.ModuleVersion)
        logDebug "Creating backup of version $($last_version.ToString())"
        logDebug "Manifest backup directory $ManifestBackupPath"

        $manifest = Get-Item (Join-Path $config.Source $config.ManifestFile)
        if (Test-Path $ManifestBackupPath) {
            $options = @{
                Destination = (Join-Path $ManifestBackupPath ( -join @(
                            $manifest.BaseName,
                            '.v',
                            $last_version.ToString(),
                            '.psd1'
                        )
                    )
                )
                Path = $manifest
            }
            Copy-Item @options
        }
    }
}
