
param(
    [Parameter()][string]$LogPath = (
        Get-BuildProperty LogPath ''
    )
)

#synopsis: If missing, create the directory where logs are stored
task confirm.logging.directory {
    if (Confirm-Path $LogPath) {
        logInfo (
            ' - {0,-16} {1}' -f 'Log files',
                ((Get-Item $LogPath) |
                Resolve-Path -Relative -ErrorAction SilentlyContinue)
        )
    } else {
        logError "Could not create $LogPath"
    }
}
