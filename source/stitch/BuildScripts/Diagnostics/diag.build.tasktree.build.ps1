
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
    Write-Build DarkBlue "Gathering tasks..."
    $tasks = Get-BuildTask

    Write-Build Gray "Total number of tasks: $($tasks.Count)"
    Write-Build Gray "$($tasks | Out-String)"
}
