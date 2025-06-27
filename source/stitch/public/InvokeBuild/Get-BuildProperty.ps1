
function Get-BuildProperty {
    <#
    .SYNOPSIS
        Return the variable specified using defined variables, environment variables and parameters
    #>
    [CmdletBinding()]
    param(
        # The name of the property
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [string]$Name,

        # The default value if one is not found
        [Parameter(
            Position = 1
        )]
        $Value
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if ($null -ne $PSCmdlet.GetVariableValue($Name)) {
            return $PSCmdlet.GetVariableValue($Name)
        } elseif ($null -ne [Environment]::GetEnvironmentVariable($Name)) {
            return [Environment]::GetEnvironmentVariable($Name)
        } elseif ($null -ne $Value) {
            return $Value
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
