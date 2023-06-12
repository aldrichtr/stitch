using namespace System.Diagnostics.CodeAnalysis


function New-StitchBuildProfile {
    [SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'File creation methods have their own ShouldProcess')]
    [CmdletBinding()]
    param(
        # The name of the profile to create
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [string]$Name,

        # Profile path in the build config path
        [Parameter(
            Position = 1,
            ValueFromPipeline
        )]
        [string]$ProfileRoot,

        # Overwrite the profile if it exists
        [Parameter(
        )]
        [switch]$Force

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if (-not ($PSBoundParameters.ContainsKey('ProfileRoot'))) {
            $possibleProfileRoot = Find-BuildProfileRootDirectory
            if ($null -ne $possibleProfileRoot) {
                $ProfileRoot = $possibleProfileRoot
                Remove-Variable $possibleProfileRoot -ErrorAction SilentlyContinue
            } else {
                throw 'Could not find the build profile root directory. Use -ProfileRoot'
            }
        }
        $newProfileDirectory = (Join-Path $ProfileRoot $Name)
        if ((Test-Path $newProfileDirectory) -and
            (-not ($Force))) {
            throw "Profile '$Name' already exists at $newProfileDirectory. Use -Force to Overwrite"
        } else {
            try {
                Write-Debug 'Creating directory'
                $null = mkdir $newProfileDirectory -Force
                Write-Debug 'Creating runbook'
                $newProfileDirectory | New-StitchRunBook -Force:$Force
                Write-Debug 'Creating configuration file'
                $newProfileDirectory | New-StitchConfigurationFile -Force:$Force
            } catch {
                throw "Could not create new build profile '$Name' in '$newProfileDirectory'`n$_"
            }
            #TODO: if we fail to create a file, should we remove the folder in a finally block?
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
