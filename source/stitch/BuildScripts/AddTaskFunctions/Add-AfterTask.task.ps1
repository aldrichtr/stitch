
Set-Alias after Add-AfterTask
function Add-AfterTask {
    <#
.SYNOPSIS
    Add tasks to run after another without needing to modify the original task
.EXAMPLE
    Build after Package

    This will ensure that the build task is run after the package

.EXAMPLE
    after Package Clean, Build
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
        $allTasks = ${*}.All.Keys
        $errorMessage = "Could not add {0} after {1}. '{2}' in not a valid task name"
    }
    process {
        if ($allTasks -contains $Name) {
        foreach ($item in $TaskList) {
                if ($allTasks -contains $item) {
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
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
