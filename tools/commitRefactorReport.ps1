$count = 1

$commits = [System.Collections.ArrayList]@(Get-GitCommit -Until main)
$commits.Reverse()



"# Refactor $(Get-GitBranch -Current | expand FriendlyName)"
""
foreach ($commit in $commits) {
    $shortSha = $commit.Sha.substring(0,7)
    "## $count pick $shortSha $($commit.MessageShort)"
    ""
    foreach ($file in ($commit | Get-CommitPatch | expand Path)) {
        "- $file"
    }
    ""
    $count++
}
