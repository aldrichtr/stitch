
Set-Alias jobs Add-JobTask
function Add-JobTask {
    <#
.SYNOPSIS
    Add tasks to the job list of another without needing to modify the original task
.EXAMPLE
    Build | jobs task1, task2

    This will add tasks `task1` and task2 to the jobs list of Build

.EXAMPLE
    jobs @(task1, task2) Build
#>
    param(
        # The primary task or phase to add the -TaskList to as jobs
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )][string]$Name,

        # The task(s) that will be added to the list of jobs in the task in -Name
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [Array]$TaskList,

        # Replace the current jobs list with the tasks in -TaskList
        # tasks in -TaskList are appended to the end by default
        [Parameter()]
        [switch]$Replace

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $allTasks = ${*}.All.Keys
        $validTasks = [System.Collections.Generic.List[object]]@()
        $errorMessage = "Could not add {0} as a job of {1}. '{2}' in not a valid task name"

        if ($allTasks -contains $Name) {
            Write-Debug "$Name is a valid task"

            foreach ($item in $TaskList) {
                if ($item -is [string]) {
                    if ($item[0] -eq '?') {
                        $taskName = $item.Substring(1)
                    } else {
                        $taskName = $item
                    }
                    if ($allTasks -contains $taskName) {
                        Write-Debug "Adding $taskName as job of $Name"
                        #! We add the original taskList item, regardless of the '?'
                        $validTasks.Add($item)
                    } else {
                        throw ($errorMessage -f $item, $Name, $item)
                    }
                } elseif ($item -is [scriptblock]) {
                    Write-Debug "Adding scriptblock as job of $Name"
                    $validTasks.Add($item)
                } elseif ($item -is [hashtable]) {
                    Add-BuildTask $Name @Jobs -Source $MyInvocation
                } else {
                    throw ("Cannot add a $($item.GetType()) as a job of $Name" )
                }
            }
        } else {
            throw ($errorMessage -f $item, $Name, $Name)
        }
    }
    end {
        if ($Replace) {
            Write-Debug '-Replace called, clearing current job list first'
            $null = ${*}.All[$Name].Jobs.Clear()
        }
        Write-Debug "Task list verified, adding $($validTasks.Count) jobs to $Name"
        ${*}.All[$Name].Jobs += $validTasks

        if ($MyInvocation.PipelinePosition -lt $MyInvocation.PipelineLength) {
            Write-Debug "Sending $Name to pipeline"
            $Name | Write-Output
        }


        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
