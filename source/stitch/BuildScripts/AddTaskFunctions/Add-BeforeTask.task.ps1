
function Add-BeforeTask {
    <#
    .SYNOPSIS
        Add tasks to run before another without needing to modify the original task
    .EXAMPLE
        Build | before Validate

        "Run 'Build' before 'Validate'"
        This will ensure that the Build task is run before the Validate task

    .EXAMPLE
        Build | before Validate
        Jobs    | before Task
        Validate.Jobs = @( 'Build' , ... )
    #>
    [Alias('before')]
    [CmdletBinding()]
    param(
        # The primary task. Jobs will be added to the end of this Task.
        [Parameter(
            Mandatory,
            Position = 0
        )][string[]]$Task,

        # The job(s) that will be run before the Task
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline
        )][string[]]$Jobs

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $allTasks     = ${*}.All.Keys
        $errorMessage = "Could not add {0} before {1}. '{2}' is not a valid task name"
        #! Create a new list to replace the Jobs list with before processing
    }
    process {
        if ($null -ne $allTasks) {
            foreach ($currentTask in $Task) {
                # Normalize the name of the Task
                $taskName   = $currentTask | Resolve-TaskName
                #! Start with the current list of Jobs

                if ($allTasks -contains $taskName) {
                    foreach ($currentJob in $Jobs) {
                        $jobName = $currentJob | Resolve-TaskName

                        # if The current job is a valid task
                        if ($allTasks -contains $jobName) {
                            # if it is not already in the job list for this task
                            if (${*}.All[$taskName].Jobs -notcontains $currentJob) {
                                Write-Debug "Adding $currentJob to beginning of $taskName Jobs"
                                ${*}.All[$taskName].Jobs.Insert(0,$currentJob)
                            } else {
                                Write-Verbose "$currentJob already a job of $currentTask"
                            }
                        } else {
                            throw ($errorMessage -f $currentJob, $currentTask, $currentJob)
                        }
                    }
                } else {
                    throw ($errorMessage -f $currentJob, $currentTask, $currentTask)
                }

                #! If we are in the pipeline, send out the Task name
                if ($MyInvocation.PipelinePosition -lt $MyInvocation.PipelineLength) {
                    $currentTask | Write-Output
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
