
param(

)

#synopsis: Pop the latest git stash off the stack
task pop.git.stash {
    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if ($null -ne $gitCmd) {
        $argumentList = @('pop')
        & $gitCmd $argumentList
    } else {
        throw (logError 'Could not find the git command on this system' -PassThru)
    }
}
