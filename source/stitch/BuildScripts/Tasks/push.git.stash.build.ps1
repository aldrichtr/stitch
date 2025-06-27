
param(
    [Parameter()][string]$GitStashMessage = (
        Get-BuildProperty GitStashMessage ''
    ),

    [Parameter()][switch]$IncludeUntrackedInGitStash = (
        Get-BuildProperty IncludeUntrackedInGitStash $false
    )
)

#synopsis: Push a git stash onto the stack
task push.git.stash {
    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if ($null -ne $gitCmd) {
        $argumentList = @('push')
        if ($IncludeUntrackedInGitStash) {
            $argumentList += '--include-untracked'
        }
        if (-not([string]::IsNullorEmpty($GitStashMessage))) {
            $argumentList += '--message', $GitStashMessage
        }
        & $gitCmd $argumentList
    } else {
        throw (logError "Could not find the git command on this system" -PassThru)
    }
}
