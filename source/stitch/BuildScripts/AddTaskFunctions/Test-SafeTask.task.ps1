
function Test-SafeTask {
    <#
    .SYNOPSIS
        Return true if the task is a "Safe Task" (One that can have terminating errors without ending the build)
    #>
    [CmdletBinding()]
    param(
        # The name of the task
        [Parameter(
            ValueFromPipeline
        )]
        [string]$Name
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        (if $Name.Substring(0,1) -eq '?') | Write-Output
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
