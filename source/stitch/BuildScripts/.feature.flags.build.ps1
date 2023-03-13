param(
    [Parameter()]
    [hashtable]$BuildInfo = (
        Get-BuildProperty BuildInfo @{
            Flags = @{}
        }
    )
)
#-------------------------------------------------------------------------------
#region Feature flag table

$featureFlags = @{
    phaseConfigFile = @{
        Enabled = $true
        Description = 'Allow the configuration of phases (jobs, input, output, etc.) from a structured text file (psd1, yaml, json)'
    }
}

#endregion Feature flag table
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Update BuildInfo

if ($null -ne $BuildInfo) {
    if ($BuildInfo.ContainsKey('Flags')) {
        #! Update our featureFlags with any that are already set first
        $featureFlags | Update-Object $BuildInfo.Flags
        #! Then "post" the Updated object back to BuildInfo
        $BuildInfo.Flags | Update-Object $featureFlags
    } else {
        $BuildInfo['Flags'] = $featureFlags
    }
}

#endregion Update BuildInfo
#-------------------------------------------------------------------------------
function Enable-FeatureFlag {
    [CmdletBinding()]
    param(
        # The name of the feature flag to test
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name
    )
    begin {
    }
    process {
                if ($null -ne $BuildInfo) {
            $BuildInfo = @{
                Flags = @{}
            }
        }
        if ($BuildInfo.ContainsKey('Flags')) {
            if ($BuildInfo.Flags.ContainsKey($Name)) {
                $BuildInfo.Flags[$Name].Enabled = $true
            } else {
                $BuildInfo.Flags[$Name] = @{
                    Enabled = $true
                    Description = "Missing description"
                }
            }
        }
    }
    end {
    }
}
function Disable-FeatureFlag {
    [CmdletBinding()]
    param(
        # The name of the feature flag to test
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name
    )
    begin {
    }
    process {
        if ($null -ne $BuildInfo) {
            $BuildInfo = @{
                Flags = @{}
            }
        }
        if ($BuildInfo.ContainsKey('Flags')) {
            if ($BuildInfo.Flags.ContainsKey($Name)) {
                $BuildInfo.Flags[$Name].Enabled = $false
            } else {
                $BuildInfo.Flags[$Name] = @{
                    Enabled = $false
                    Description = "Missing description"
                }
            }
        }
    }
    end {
    }
}

function Test-FeatureFlag {
    [CmdletBinding()]
    param(
        # The name of the feature flag to test
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
    if ($null -ne $BuildInfo) {
        if ($BuildInfo.ContainsKey('Flags')) {
            if ($BuildInfo.Flags.ContainsKey($Name)) {
                $BuildInfo.Flags[$Name].Enabled
            }
        }
    }
}

function Get-FeatureFlag {
    [CmdletBinding()]
    param(
        # The name of the feature flag to test
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
    if ($null -ne $BuildInfo) {
        if ($BuildInfo.ContainsKey('Flags')) {
            if ($BuildInfo.Flags.ContainsKey($Name)) {
                $BuildInfo.Flags[$Name]
            }
        }
    }
}
