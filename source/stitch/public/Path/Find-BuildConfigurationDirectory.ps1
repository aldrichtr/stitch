function Find-BuildConfigurationDirectory {
    <#
    .SYNOPSIS
        Find the directory that contains the build configuration for the given profile
    #>
    [Alias('Resolve-BuildConfigurationDirectory')]
    [CmdletBinding()]
    param(
        # The BuildProfile to use
        [Parameter(
        )]
        [string]$BuildProfile
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $Options = @{
            Option = 'Constant'
            Name = 'DEFAULT_BUILD_PROFILE'
            Value = 'default'
            Description = 'The default build profile'
        }

        New-Variable @Options
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('BuildProfile'))) {
            $possibleBuildProfile = $PSCmdlet.GetVariableValue('BuildProfile')
            if ($null -ne $possibleBuildProfile) {
                $BuildProfile = $possibleBuildProfile
            }
        }

        if ([string]::IsNullorEmpty($BuildProfile)) {
            $BuildProfile = $DEFAULT_BUILD_PROFILE
        }

        $possibleProfileRoot = Find-BuildProfileRootDirectory

        if ($null -ne $possibleProfileRoot) {
            $possibleBuildProfilePath = (Join-Path -Path $possibleProfileRoot -ChildPath $BuildProfile)
            if (Test-Path $possibleBuildProfilePath) {
                Get-Item $possibleBuildProfilePath | Write-Output
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
