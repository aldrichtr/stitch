param(
    # Specifies a path to one or more locations.
    [Parameter(
    Position = 0,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName
    )]
    [Alias('PSPath')]
    [string[]]$Path,

    # Do not print region marks
    [Parameter(
    )]
    [switch]$NoRegionMarks,

    # Show the line number and level of message
    [Parameter(
    )]
    [switch]$WithLineNumbers
)

$currentLevel = 0
$inRegion = $false
if (Test-Path $Path) {
    switch -Regex -File $Path {
        '^(#{2,3}) (\d+) (\w+) (.*)$' {
            $level = ($Matches.1).Length
            $originalLineNumber = $Matches.2
            $action = $Matches.3
            $message = $Matches.4
            if (-not($NoRegionMarks)) {
                if (($inRegion) -and ($level -eq $regionLevel)) {
                    # reset the level
                    $inRegion = $false
                    "# --"
                    $regionLevel = $level
                }
            }
            if ($WithLineNumbers){
                "$originalLineNumber $level $action $message"
            } else {
                "$action $message"
            }

            continue
        }
        '^(#+) region (.*)' {
            $inRegion = $true
            $regionName = $Matches.2
            $regionlevel = ($Matches.1).Length
            "# -- $regionName"
            continue
        }
        default {

        }
    }
    @'

# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup [-C | -c] <commit> = like "squash" but keep only the previous
#                    commit's log message, unless -C is used, in which case
#                    keep only this commit's message; -c is same as -C but
#                    opens the editor
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
#         create a merge commit using the original merge commit's
#         message (or the oneline, if no original merge commit was
#         specified); use -c <commit> to reword the commit message
# u, update-ref <ref> = track a placeholder for the <ref> to be updated
#                       to this position in the new commits. The <ref> is
#                       updated at the end of the rebase
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
'@
}
