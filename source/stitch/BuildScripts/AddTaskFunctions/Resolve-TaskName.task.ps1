
function Resolve-TaskName {
    <#
    .SYNOPSIS
        Get the task name from the given string.  A task name may be preceded by a '?'
    #>
    [CmdletBinding()]
    param(
        # The task name to check
        [Parameter(
            ValueFromPipeline
        )]
        [object]$Task
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Task)`n$('-' * 80)"
    }
    process {
        if ($Task -is [string]) {
            if ($Task[0] -eq '?') {
                $Task.Substring(1) | Write-Output
            } else {
                $Task | Write-Output
            }
        }
        elseif ($Task -is [scriptblock]) {
            $Task | Write-Output
        }
        else {
            throw "Invalid Task name $Task"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Task)`n$('-' * 80)"
    }
}
