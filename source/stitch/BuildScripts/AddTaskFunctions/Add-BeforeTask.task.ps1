
Set-Alias before Add-BeforeTask
function Add-BeforeTask {
    <#
.SYNOPSIS
    Add tasks to run before another without needing to modify the original task
.EXAMPLE
    Build | before Package

    This will ensure that the build task is run before the package

.EXAMPLE
    before Package Clean, Build
#>
    param(
        # The primary task to add the TaskList to the 'Before' array
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [string]$Name,

        # The task(s) that will be run before the task Name
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline
        )]
        [string[]]$TaskList

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $allTaskNames = ${*}.All.Keys
        $errorMessage = "Could not add {0} before {1}. '{2}' in not a valid task name"

        if ($allTaskNames -contains $Name) {
            Write-Debug "$Name is a valid task"
            foreach ($item in $TaskList) {
                if ($allTaskNames -contains $item) {
                    Write-Debug "Adding $item to Before list of $Name"

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
        if ($MyInvocation.PipelinePosition -lt $MyInvocation.PipelineLength) {
            Write-Debug "Sending $Name to pipeline"
            $Name | Write-Output
        }


        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
