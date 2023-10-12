
function Invoke-OutputHook {
    [CmdletBinding()]
    param(
        # Function to run the hook for
        [Parameter(
            Position = 0,
            Mandatory
        )]
        [ValidateSet(
            'EnterBuild', 'ExitBuild',
            'EnterBuildTask', 'ExitBuildTask',
            'EnterBuildJob', 'ExitBuildJob',
            'SetBuildHeader', 'SetBuildFooter'
        )]
        [string]$Function,

        # The stage of the function to run the hook
        [Parameter(
            Position = 1
        )]
        [ValidateSet('Before', 'After')]
        [string]$Stage
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (Test-FeatureFlag 'buildOutputHook') {
            if ($null -ne $Output) {
                if ($Output.ContainsKey($Function)) {
                    if ($Output[$Function].ContainsKey($Stage)) {
                        if ($Output[$Function][$Stage] -is [scriptblock]) {
                            $Output[$Function][$Stage].invoke()
                        } elseif ($Output[$Function][$Stage] -is [string]) {
                            $Output[$Function][$Stage]
                        }
                    }
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
