function Test-FeatureFlag {
    <#
    .SYNOPSIS
        Test if a feature flag is enabled
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        # The name of the feature flag to test
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $flag = Get-FeatureFlag -Name $Name

        if ([string]::IsNullorEmpty($flag)) {
            $false
        } else {
            $flag.Enabled
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
