
function New-StitchPathConfigurationFile {
    [CmdletBinding()]
    param(
        # Default Source directory
        [Parameter(
        )]
        [string]$Source,

        # Default Tests directory
        [Parameter(
        )]
        [string]$Tests,

        # Default Staging directory
        [Parameter(
        )]
        [string]$Staging,

        # Default Artifact directory
        [Parameter(
        )]
        [string]$Artifact,

        # Default Docs directory
        [Parameter(
        )]
        [string]$Docs,

        # Do not validate paths
        [Parameter(
        )]
        [switch]$DontValidate,

        # Overwrite an existing file
        [Parameter(
        )]
        [switch]$Force
    )
begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    $defaultPathConfigFile = (Join-Path (Get-Location) '.stitch.config.psd1')
    $locations = @{
        Source = @{}
        Tests = @{}
        Staging = @{}
        Artifacts = @{}
        Docs = @{}
    }
}
process {
    Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    foreach ($location in $locations.Keys) {
        if (-not ($PSBoundParameters.ContainsKey($location))) {
            $pathIsSet = $false
            do {
                $ans = Read-Host "The directory where this project's $location is stored: "
                if (-not ($DontValidate)) {
                    $possiblePath = (Join-Path (Get-Location) $ans)
                    if (-not (Test-Path $possiblePath)) {
                        $confirmAnswer = Read-Host "$possiblePath does not exist. Use anyway?"
                        if (([string]::IsNullorEmpty($confirmAnswer)) -or
                            ($confirmAnswer -match '^[yY]')) {
                                $PSBoundParameters[$location] = $ans
                                $pathIsSet = $true # break out of loop for this location
                        }
                    }
                } else {
                    $pathIsSet = $true
                }
            } while (-not ($pathIsSet))
        }
    }

    $pathSettings = $PSBoundParameters

    foreach ($unusedParameter in @('DontValidate', 'Force')) {
        if ($pathSettings.ContainsKey($unusedParameter)) {
            $null = $pathSettings.Remove($unusedParameter)
        }
    }

    if (Test-Path $defaultPathConfigFile) {
        if ($Force) {
            if ($PSCmdlet.ShouldProcess("$defaultPathConfigFile", "Overwrite existing file")) {
                $pathSettings | Export-Psd -Path $defaultPathConfigFile
            }
        }
    }


    Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
}
end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
}
}
