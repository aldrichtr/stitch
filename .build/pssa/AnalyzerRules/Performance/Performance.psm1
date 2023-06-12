#TODO: Performance of array insertion
# https://stackoverflow.com/questions/60708578 += is expensive
#TODO: See
#https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/security/preventing-script-injection?view=powershell-7.3


function Measure-AvoidAddingToArrayWithPlusEqual {
    <#
    .SYNOPSIS
    The use of the operator '+=' on an array is expensive
    .DESCRIPTION
        Using '+=' for adding items to an array is expensive, because the array has a fixed size and the addition
        creates a new array big enough to hold all the elements.  Consider using a typed generic list
    .LINK
        https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.3
    #>
    [CmdletBinding()]
    param(
        # The scriptblock to measure
        [Parameter(
        )]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
