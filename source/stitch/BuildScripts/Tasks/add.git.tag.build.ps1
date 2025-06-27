param(
    [Parameter()][string]$GitTagVersionField = (
        Get-BuildProperty GitTagVersionField 'MajorMinorPatch'
    )
)

#synopsis: Create a git tag for the current version
task add.git.tag {
    $gitCmd = Get-Command git
    if ($null -ne $gitCmd) {
        $cmd = $gitCmd.Source
        $latestVersion = $BuildInfo.Project.Version[$GitTagVersionField]
        if ($null -ne $latestVersion) {
            $tag = "v$latestVersion"
            logInfo "Setting git tag $tag"
            & $cmd @('tag', $tag)
        } else {
            throw 'Latest version information not present in BuildInfo'
        }
    } else {
        throw 'Could not find git on this system'
    }
}
