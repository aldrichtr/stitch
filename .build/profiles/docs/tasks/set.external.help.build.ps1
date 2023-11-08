
#SYNOPSIS: Remove the Comment-based help in the given file and replace it with `.EXTERNALHELPFILE
task set.external.help {
    $BuildInfo | Foreach-Module {
        $config = $_
        $externalHelpText = @"
    <#
    .EXTERNALHELPFILE $($config.Name)-help.xml
    #>
"@
        $functions = $config.SourceInfo | Where-Object Type -Like 'function'
        foreach ($source in $functions) {
            if ($null -ne $env:TestExternalHelp) {
                if ($source.Name -notlike $env:TestExternalHelp) {
                    continue
                } else {
                    logInfo "TestExternalHelp is set to $env:TestExternalHelp"
                    logInfo "processing File"
                }
            }
            if ($source.Tokens.Count -gt 0) {
                $commentBasedHelp = $source.Tokens | Where-Object {
                    ($_.Kind -like 'Comment' ) -and
                    ($_.Extent.Text -match '\.SYNOPSIS' )
                }
            }
            if ($null -ne $commentBasedHelp) {
                logInfo "$($source.Name) has comment-based help"
                #! in Get-SourceItemInfo ToString is overloaded to output the content of the file
                $content = $source.ToString()
                $start = ($commentBasedHelp.Extent.StartOffSet - 1)
                $end = ($commentBasedHelp.Extent.EndOffset + 1)

                logInfo "help starts at $start and ends at $end"
                logInfo "Help Content:`n$(-join ($content[$start..$end]))"

                # Now we "splice" the content
                logInfo "Splicing content"
                $preComment = (-join ($content[0..$start]))
                $postComment = (-join ($content[$end..-1]))

                $preComment, $externalHelpText, $postComment | Set-Content $source.Path

            }
        }
    }
}
