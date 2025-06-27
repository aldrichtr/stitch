
function Get-TaskHelp {
    <#
    .SYNOPSIS
        Retrieve the comment based help for the given task
    .NOTES
        If the given task's file does not have help info, it won't be very helpful...
    #>
    [CmdletBinding()]
    param(
        # The name of the task to get the help documentation for
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ArgumentCompleter({ Invoke-TaskNameCompletion @args})]
        [string[]]$Name,

        # The InvocationInfo of a task
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [System.Management.Automation.InvocationInfo]$InvocationInfo
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if ($PSBoundParameters.ContainsKey('InvocationInfo')) {
            Get-Help $InvocationInfo.ScriptName -Full
        } elseif ($PSBoundParameters.ContainsKey('Name')) {
            foreach ($taskName in $Name) {
                $task = Get-BuildTask -Name $taskName
                if ($null -ne $task) {
                    Get-Help $task.InvocationInfo.ScriptName -Full
                }
            }
        } else {
            throw "No task given"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
