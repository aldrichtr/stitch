
param(
    [Parameter()][string]$ChangelogBackupPath = (
        Get-BuildProperty ChangelogBackupPath ''
    ),

    [Parameter()][string]$ManifestBackupPath = (
        Get-BuildProperty ManifestBackupPath ''
    )
)

#synopsis: If missing, create the directory where backups are stored
task confirm.backup.directory {
    if (Confirm-Path $ChangelogBackupPath) {
        logInfo (
            ' - {0,-16} {1}' -f 'Changelog Backups',
                ((Get-Item $ChangelogBackupPath) |
                Resolve-Path -Relative -ErrorAction SilentlyContinue)
        )
    } else {
        logError "Could not create $ChangelogBackupPath"
    }
    if (Confirm-Path $ManifestBackupPath) {
        logInfo (
            ' - {0,-16} {1}' -f 'Manifest Backups',
                ((Get-Item $ManifestBackupPath) |
                Resolve-Path -Relative -ErrorAction SilentlyContinue)
        )
    } else {
        logError "Could not create $ManifestBackupPath"
    }
    if (Confirm-Path $ManifestBackupPath) {
        logInfo (
            ' - {0,-16} {1}' -f 'Manifest Backups',
                ((Get-Item $ManifestBackupPath) |
                Resolve-Path -Relative -ErrorAction SilentlyContinue)
        )
    } else {
        logError "Could not create $ManifestBackupPath"
    }
}
