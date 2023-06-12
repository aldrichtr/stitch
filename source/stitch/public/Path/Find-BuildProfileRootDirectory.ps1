
function Find-BuildProfileRootDirectory {
    <#
    .SYNOPSIS
        Find the directory that has the profiles defined
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to a location that contains Build Profiles (This should  be BuildConfigPath)
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $possibleProfileDirectories = @(
            'profiles',
            'profile',
            'runbooks'
        )
        $profileDirectory = $null
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            $possibleBuildConfigRoot += $PSCmdlet.GetVariableValue('BuildConfigRoot')
            if ([string]::IsNullorEmpty($possibleBuildConfigRoot)) {
                $Path += Get-Location
            } else {
                $Path += $possibleBuildConfigRoot
            }
        }

        :root foreach ($possibleRootPath in $Path) {
            :profile foreach ($possibleProfileDirectory in $possibleProfileDirectories) {
                $possibleProfilePath = (Join-Path $possibleRootPath $possibleProfileDirectory)
                if (Test-Path $possibleProfilePath) {
                    $possiblePathItem = (Get-Item $possibleProfilePath)
                    if ($possiblePathItem.PSIsContainer) {
                        $profileDirectory = $possibleProfilePath
                    } else {
                        $profileDirectory = $possibleProfilePath | Split-Path -Parent
                    }
                    Write-Debug "Found profile root directory '$profileDirectory'"
                    break root
                }
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        $profileDirectory
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
