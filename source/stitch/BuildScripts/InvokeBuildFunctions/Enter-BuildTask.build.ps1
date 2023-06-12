
Enter-BuildTask {
    if ($GithubOutputEnabled) {
        Enter-ActionOutputGroup -Name $Task.Name
    }
    Invoke-OutputHook 'EnterBuildTask' 'Before'


    Invoke-OutputHook 'EnterBuildTask' 'After'
}
