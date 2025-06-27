
param(
    [Parameter()][string]$HelpDocLogFile = (
        Get-BuildProperty HelpDocLogFile ''
    )
)

#synopsis: Update the existing markdown documents using the comment-based help
task update.markdownhelp.file {
     $BuildInfo | Foreach-Module {
        $config = $_
        $name = $config.Name
        logInfo "checking for markdown files in $($config.Docs)"
        $pages = Get-ChildItem -Path $config.Docs -Filter '*.md'

        if (($null -ne $pages) -or ($pages.Count -eq 0)) {
            logWarn '  No markdown pages to update.'
        } else {
            logInfo "  Updating markdown help files for $name"
            foreach ($page in $pages) {
                $cmd = $page.BaseName
                # if the basename is not the module name
                if ($cmd -ne $name) {
                    $docOptions = @{
                        Path                  = (Join-Path $config.Docs "$cmd.md")
                        AlphabeticParamsOrder = $true
                        UpdateInputOutput     = $true
                        ExcludeDontShow       = $true
                        Encoding              = [System.Text.Encoding]::UTF8
                    }
                    if (-not([string]::IsNullorEmpty($HelpDocLogFile))) {
                        $docOptions['LogPath']               = $HelpDocLogFile
                    }
                    logInfo "   - Updating help for $cmd"

                    Update-MarkdownHelp @docOptions
                } else {
                    # we encountered a module page.  Refresh it with any
                    logInfo '  Now updating the module page'
                    Update-MarkdownHelpModule -Path $config.Docs -RefreshModulePage
                }
            }
        }
    }
}
