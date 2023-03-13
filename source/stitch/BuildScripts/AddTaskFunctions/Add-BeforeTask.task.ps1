
Set-Alias before Add-BeforeTask
function Add-BeforeTask {
    <#
.SYNOPSIS
    Add tasks to run before another without needing to modify the original task
.EXAMPLE
    Build before Package

    This will ensure that the build task is run before the package

.EXAMPLE
    before Package Clean, Build
#>
    param(
        # The primary task that requires the TaskList to be run first
        [Parameter(
            Mandatory,
            Position = 0
        )][string]$Name,

        # The task(s) that will be run before the task Name
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline
        )][string[]]$TaskList

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $allTasks = ${*}.All.Keys
        $errorMessage = "Could not add {0} before {1}. '{2}' in not a valid task name"
    }
    process {
        if ($allTasks -contains $Name) {
            foreach ($item in $TaskList) {
                if ($allTasks -contains $item) {
                    ${*}.All[$item].Before += $Name
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
