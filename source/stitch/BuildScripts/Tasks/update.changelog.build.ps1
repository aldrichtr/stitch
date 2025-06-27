param(
    [Parameter()][string]$ChangelogVersionField = (
        Get-BuildProperty ChangelogVersionField 'MajorMinorPatch'
    )
)

#synopsis: Move unreleased changes to new release section and create new Unreleased section
task update.changelog {
    if ($null -ne $ChangelogPath) {
        if (Test-Path $ChangelogPath) {
            $currentVersion = [System.Version]$BuildInfo.Project.Version[$ChangelogVersionField]
            $lastVersion = [System.Version](Get-ChangelogData $ChangelogPath |
                    Select-Object -ExpandProperty LastVersion)
            if ($null -ne $lastVersion) {
                if ($currentVersion -gt $lastVersion) {
                    logInfo "Updating $ChangelogPath from $lastVersion to $currentVersion`n"

                    #region UpdateChangelog
                    logDebug "  Creating Changelog for version $($currentVersion.ToString())"
                    logDebug '   Moving changes to new release section'
                    $options = @{
                        Path           = $ChangelogPath
                        ReleaseVersion = $currentVersion.ToString()
                        LinkMode       = 'Automatic'
                        LinkPattern    = @{
                            FirstRelease  = ( -join @($config.ProjectUri, '/tree/v{CUR}'))
                            NormalRelease = ( -join @($config.ProjectUri, '/compare/v{PREV}..v{CUR}'))
                            Unreleased    = ( -join @($config.ProjectUri, '/compare/v{CUR}..HEAD'))
                        }
                    }
                    try {
                        Update-Changelog @options
                    } catch {
                        throw "There was an error updating Changelog from $lastVersion to $currentVersion`n$_"
                    }
                    #endregion UpdateChangelog
                } else {
                    logDebug " Changelog already at version $lastVersion"
                }
            } else {
                logWarn "There was an error determining the last version in $ChangelogPath"
            }
        } else {
            logWarn "No changelog found at $ChangelogPath"
        }
    } else {
        logWarn "ChangelogPath parameter was not set"
    }
}
