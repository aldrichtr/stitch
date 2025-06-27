param(
    [Parameter()]
    [string]$ChangelogBackupPath = (
        Get-BuildProperty ChangelogBackupPath (Join-Path $Artifact 'backup')
    ),
    [Parameter()]
    [string]$ChangelogPath = (
        Get-BuildProperty ChangelogPath (Join-Path $BuildRoot 'CHANGELOG.md')
    ),

    [Parameter()]
    [switch]$KeepChangelogBackup = (
        Get-BuildProperty KeepChangelogBackup $false
    )
)
#synopsis: Restore the Changelog from the last backup
task restore.changelog {
    if (Test-Path $ChangelogBackupPath) {
        if (Test-Path $ChangelogPath) {
            $changelog = Get-ChildItem $ChangelogPath
            $backups = Get-ChildItem -Path $ChangelogBackupPath -Filter "$($changelog.BaseName).v*"
            switch ($backups.Count) {
                0 {
                    logDebug "No backups found for $ChangelogBackupPath"
                }
                1 {
                    logInfo "Restoring changelog from $(Resolve-Path $backups[0].FullName)"
                    $backups[0] | Move-Item -Destination $ChangelogPath -Force
                }
                Default {
                    logDebug "$($backups.Count) backups found"
                    #? I probably could just sort the backups and take the last one, but this way
                    #? I'm guaranteed to get a "versioned" backup
                    $lastBackup = $backups[0]
                    foreach ($backup in $backups) {
                        $lastVersion = [System.Version]($lastBackup.BaseName -replace [regex]::Escape("$($changelog.BaseName).v") , '')
                        $itemVersion = [System.Version]($backup.BaseName -replace [regex]::Escape("$($changelog.BaseName).v") , '')
                        if ($itemVersion -gt $lastVersion) {
                            $lastBackup = $backup
                        }
                    }
                    logDebug "Restoring changelog from $(Resolve-Path $backup.FullName)"
                    if ($KeepChangelogBackup) {
                        $backup | Copy-Item -Destination $ChangelogPath -Force
                    } else {
                        $backup | Move-Item -Destination $ChangelogPath -Force
                    }
                }
            }
        } else {
            logWarn "$ChangelogPath does not exist"
        }
    } else {
        logWarn "$ChangelogBackupPath does not exist"
    }
}
