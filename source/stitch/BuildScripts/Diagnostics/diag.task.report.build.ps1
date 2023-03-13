
task diag.task.report {

    Write-Build DarkGray 'Loading tasks'
    $allTasks = Get-BuildTask

    foreach ( $phase in ($allTasks | Where-Object -Property IsPhase -EQ $true)) {
        Clear-Host
        Show-Taskhelp -Task $phase.Name -Format 'Out-TaskHelp'
        'Press q to quit or any other key to continue ...'
        $x = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        if ($x -match '[qQ]') {return}
    }
}
