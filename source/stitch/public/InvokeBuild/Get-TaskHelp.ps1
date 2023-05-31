function Get-TaskHelp {
    <#
    .SYNOPSIS
        Retrieve the comment based help for the given task
    #>
    [CmdletBinding()]
    param(
        # The name of the task to get the help documentation for
        [Parameter(
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
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if ($PSBoundParameters.ContainsKey('InvocationInfo')) {
            Get-Help $InvocationInfo.ScriptName -Full
        } else {
            $task = Get-BuildTask -Name:$Name
            if ($null -ne $task) {
                Get-Help $task.InvocationInfo.ScriptName -Full
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
