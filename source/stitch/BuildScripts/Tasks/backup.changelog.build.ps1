param(
    [Parameter()]
    [string]$ChangelogBackupPath = (
        Get-BuildProperty ChangelogBackupPath (Join-Path (Get-BuildProperty Artifact) 'backup')
    ),
    [Parameter()]
    [string]$ChangelogPath = (
        Get-BuildProperty ChangelogPath (Join-Path $BuildRoot 'CHANGELOG.md')
    )
)

#synopsis: Create a backup of the changelog file
task backup.changelog {
    if (Test-Path $ChangelogBackupPath) {
        logWarn "$ChangelogBackupPath needs to be created"
        New-Item -Path $ChangelogBackupPath -ItemType Directory -Force
    }

    if (Test-Path $ChangelogPath) {
        $currentVersion = [System.Version]$BuildInfo.Project.Version.MajorMinorPatch
        $lastVersion = [System.Version](Get-ChangelogData $ChangelogPath |
                Select-Object -ExpandProperty LastVersion)
        if ($null -ne $lastVersion) {
            if ($currentVersion -gt $lastVersion) {
                logDebug "  Creating backup of changelog prior to update ($lastVersion)"
                $changelogItem = Get-Item $ChangelogPath
                $backup = (Join-Path $changelogItem.Directory "$($changelogItem.BaseName).v$($lastVersion.ToString()).md")
                if (Test-Path $backup) {
                    logWarn "  **Overwriting previous backup $backup"
                }
                $changelogItem | Copy-Item -Destination $backup -Force
            }
        }
    } else {
        logWarn "$ChangelogPath does not exist"
    }
}
