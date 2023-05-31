
Set-Alias after Add-AfterTask
function Add-AfterTask {
    <#
.SYNOPSIS
    Add tasks to run after another without needing to modify the original task
.EXAMPLE
    Package | after Build

    This will ensure that the Package task is run after the Build task

.EXAMPLE
    Package | after Clean, Build
#>
    param(
        # The primary task that requires the TaskList to be run first
        [Parameter(
            Mandatory,
            Position = 0
        )][string]$Name,

        # The task(s) that will be run after the task Name
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline
        )][string[]]$TaskList

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $allTasks = ${*}.All.Keys
        $errorMessage = "Could not add {0} after {1}. '{2}' in not a valid task name"

        if ($allTasks -contains $Name) {
            Write-Debug "$Name is a valid task"
            foreach ($item in $TaskList) {
                    if ($allTasks -contains $item) {
                        Write-Debug "Adding $item to After list of $Name"
                        ${*}.All[$item].After += $Name
                    } else {
                        throw ($errorMessage -f $item, $Name, $item)
                    }
            }
        } else {
            throw ($errorMessage -f $item, $Name, $Name)
        }
    }
    end {
        if ($MyInvocation.PipelinePosition -lt $MyInvocation.PipelineLength) {
            Write-Debug "Sending $Name to pipeline"
            $Name | Write-Output
        }
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
