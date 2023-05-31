function Disable-FeatureFlag {
    [CmdletBinding()]
    param(
        # The name of the feature flag to disable
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name,

        # The description of the feature flag
        [Parameter(
        )]
        [string]$Description
    )
    begin {
        #TODO: I'm relying on BuildInfo, because I don't see a scenario right now where we would use this without it
    }
    process {
        if ($null -ne $BuildInfo) {
            if ($BuildInfo.Keys -contains 'Flags') {
                if ($BuildInfo.Flags.ContainsKey($Name)) {
                    $BuildInfo.Flags[$Name].Enabled = $true
                } else {
                    $BuildInfo.Flags[$Name] = @{
                        Enabled = $true
                        Description = $Description ?? "Missing description"
                    }
                }
            }
        }
    }
    end {
    }
}
