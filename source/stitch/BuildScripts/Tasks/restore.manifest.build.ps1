param(
    [Parameter()]
    [string]$ManifestBackupPath = (
        Get-BuildProperty ManifestBackupPath (Join-Path $Artifact 'backup')
    ),

    [Parameter()]
    [switch]$KeepManifestBackup = (
        Get-BuildProperty KeepManifestBackup $false
    )
)
#synopsis: Restore the manifests from the last backup
task restore.manifest {
    if (Test-Path $ManifestBackupPath) {
         $BuildInfo | Foreach-Module {
            $config = $_
            $name = $config.Name

            $manifest = Get-Item (Join-Path $config.Source $config.ManifestFile)

            $backups = Get-ChildItem -Path $ManifestBackupPath -Filter "$($manifest.BaseName).v*"
            switch ($backups.Count) {
                0 {
                    logDebug "No backups found for $name manifest in $ManifestBackupPath"
                }
                1 {
                    logInfo "Restoring $name manifest from $(Resolve-Path $backups[0].FullName)"
                    $backups[0] | Copy-Item -Destination $ManifestBackupPath -Force
                }
                Default {
                    logDebug "$($backups.Count) backups found"
                    #? I probably could just sort the backups and take the last one, but this way
                    #? I'm guaranteed to get a "versioned" backup
                    $lastBackup = $backups[0]
                    foreach ($backup in $backups) {
                        $lastVersion = [System.Version]($lastBackup.BaseName -replace [regex]::Escape("$($manifest.BaseName).v") , '')
                        $itemVersion = [System.Version]($backup.BaseName -replace [regex]::Escape("$($manifest.BaseName).v") , '')
                        if ($itemVersion -gt $lastVersion) {
                            $lastBackup = $backup
                        }
                    }
                    logDebug "Restoring manifest from $(Resolve-Path $backup.FullName)"
                    if ($KeepManifestBackup) {
                        $backup | Copy-Item -Destination $manifest.FullName -Force
                    } else {
                        $backup | Move-Item -Destination $manifest.FullName -Force
                    }
                }
            }
        }
    } else {
        logWarn "$ManifestBackupPath does not exist"
    }
}
