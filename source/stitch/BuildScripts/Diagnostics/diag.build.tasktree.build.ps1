
#synopsis: Output a tree view of the tasks with their synopsis
task diag.build.tasktree {
    <#------------------------------------------------------------------
     "phases" is an arbitrary concept.  If the task is defined as phase
     then we consider that to be "top-level" tasks.  A phase can have
     any amount of subtasks, but the concept is that:
      - A phase defines a _process_ to be done
      - task is a unit of work
      - job an "atomic" unit of work. "do one thing"
    ------------------------------------------------------------------#>
    $all_tasks = @()

    foreach ($key in ${*}.All.Keys) {
        $task = ${*}.All[$key]
        $task | Add-Member -NotePropertyName Synopsis -NotePropertyValue (Get-BuildSynopsis $task)
        $task | Add-Member -NotePropertyName phase -NotePropertyValue (( $task.InvocationInfo.InvocationName -like 'phase' ) ? $true : $false)
        $task | Add-Member -NotePropertyName File -NotePropertyValue (Get-Item $task.InvocationInfo.ScriptName)
        $task | Add-Member -NotePropertyName Line -NotePropertyValue $task.InvocationInfo.ScriptLineNumber
        $all_tasks += $task
    }

    logInfo "A total of $($all_tasks.Count) tasks"

    foreach ( $phase in ($all_tasks | Where-Object -Property phase -EQ $true)) {
        Write-Build DarkGreen "$($phase.Name) - $($phase.Synopsis)"
        foreach ($j in $phase.Jobs) {
            $job = $all_tasks | Where-Object -Property Name -Like $j
            if ($null -ne $job) {
                Write-Build White (' - {0,-48} {1}' -f "$($job.Name) ($($job.File.BaseName -replace '\.build$', ''):$($job.Line))", $job.Synopsis)
            }
        }
        Write-Build White ''
    }
}
