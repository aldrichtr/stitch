
function Get-FeatureFlag {
    <#
    .SYNOPSIS
        Retrieve feature flags for the stitch module
    #>
    [CmdletBinding()]
    param(
        # The name of the feature flag to test
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Name
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $featureFlagFile = (Join-Path (Get-ModulePath) 'feature.flags.config.psd1')
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if ($null -ne $BuildInfo.Flags) {
            Write-Debug "Found the buildinfo table and it has Flags set"
            $featureFlags = $BuildInfo.Flags
        } elseif ($null -ne $featureFlagFile) {
            if (Test-Path $featureFlagFile) {
                $featureFlags = Import-Psd $featureFlagFile -Unsafe
            }
        }

        if ($null -ne $featureFlags) {
            switch ($featureFlags) {
                ($_ -is [System.Collections.Hashtable]) {
                    foreach ($key in $featureFlags.Keys) {
                        $flag =  $featureFlags[$key]
                        $flag['PSTypeName'] = 'Stitch.FeatureFlag'
                        $flag['Name'] = $key

                        if ((-not ($PSBoundParameters.ContainsKey('Name'))) -or
                        ($flag.Name -like $Name)) {
                            [PSCustomObject]$flag | Write-Output
                        }
                        continue
                    }
                }
                default {
                    foreach ($flag in $featureFlags.PSobject.properties) {
                        Write-Debug "Name is $($flag.Name)"
                        if ((-not ($PSBoundParameters.ContainsKey('Name'))) -or
                        ($flag.Name -like $Name)) {
                            $flag | Write-Output
                        }
                    }
                }
            }
        } else {
            Write-Information "No feature flag data was found"
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
