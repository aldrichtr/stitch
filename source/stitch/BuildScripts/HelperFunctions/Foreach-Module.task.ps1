using namespace System.Diagnostics.CodeAnalysis


function Foreach-Module {
    <#
    .SYNOPSIS
    Iterate through the ModuleInfo objects in the current project
    .DESCRIPTION
    Available as a "short-cut" to writing
    ```powershell
    foreach ($key in $BuildInfo.Modules.Keys) {
        $config = $BuildInfo.Modules[$key]
        ...
    }
    ```
    .EXAMPLE
    $BuildInfo | Foreach-Module {
        $config = $_
        ...
    }
    #>
    [SuppressMessage('PSUseApprovedVerbs', '', Justification = 'Foreach is a common idiom for looping through items')]
    [CmdletBinding()]
    param(
        # The buildinfo for the current project
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [object]$BuildInfo,

        # The scriptblock to execute on each module
        [Parameter(
            Position = 0
        )]
        [scriptblock]$ScriptBlock
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $variableCollection = [System.Collections.Generic.List[System.Management.Automation.PSVariable]]@()
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        foreach ($key in $BuildInfo.Modules.Keys) {
            $itemVariable = New-Object System.Management.Automation.PSVariable @('_', $BuildInfo.Modules[$key])
            $variableCollection += $itemVariable
            try {
                $ScriptBlock.InvokeWithContext(@{}, $variableCollection, @()) | Write-Output
                $variableCollection.Clear()
            }
            catch {
                #! if the invocation throws an exception, we want to give the user _that_ one, not the one
                #! _from_ the invocation
                throw $_.Exception.InnerException
            }
        }

        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
