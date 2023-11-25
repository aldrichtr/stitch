
Exit-Build {
    Invoke-OutputHook 'ExitBuild' 'Before'
    Invoke-BuildNotification -Status 'Passed' -LogFile (Join-Path $LogPath $LogFile)
    Invoke-OutputHook 'ExitBuild' 'After'
}
