
Exit-BuildTask {
    Invoke-OutputHook 'ExitBuildTask' 'Before'
    Invoke-OutputHook 'ExitBuildTask' 'After'
    if ($GithubOutputEnabled) {
        Exit-ActionOutputGroup
    }
}
