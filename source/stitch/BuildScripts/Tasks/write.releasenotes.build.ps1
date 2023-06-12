
param(
    [Parameter()][string]$ChangelogPath = (
        Get-BuildProperty ChangeLogPath
    ),


    [Parameter()][string]$ReleaseNotesFile = (
        Get-BuildProperty ReleaseNotesFile 'ReleaseNotes.md'
    )
)
#synopsis: Generate release notes from the changelog
task write.releasenotes {
     $BuildInfo | Foreach-Module {
        $config = $_

        $options = @{
            Path        = $ChangelogPath
            Destination = (Join-Path $config.Staging $ReleaseNotesFile)
        }
        if (Test-Path $options.Path) {
            logDebug '  Creating Release Notes'
            logDebug "   $ChangelogPath -> $($options.OutputPath)"
            Export-ReleaseNotes @options
            Remove-Variable options
        } else {
            logWarn "Could not find a changelog at $ChangelogPath"
        }
    }
}
