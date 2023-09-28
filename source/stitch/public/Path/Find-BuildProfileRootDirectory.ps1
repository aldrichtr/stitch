
function Find-BuildProfileRootDirectory {
    <#
    .SYNOPSIS
        Find the directory that has the profiles defined
    #>
    [Alias('Resolve-BuildProfileRootDirectory')]
    [CmdletBinding()]
    param(
        # Specifies a path to a location that contains Build Profiles (This should be BuildConfigPath)
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [AllowEmptyString()]
        [AllowNull()]
        [string[]]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        $possibleProfileDirectories = @( 'profiles', 'profile', 'runbooks' )
        $profileDirectory = $null
    }
    process {
        if ([string]::IsNullorEmpty($Path)) {
            $possibleBuildConfigRoot = Find-BuildConfigurationRootDirectory

            if ([string]::IsNullorEmpty($possibleBuildConfigRoot)) {
                $Path += Get-Location
            } else {
                $Path += $possibleBuildConfigRoot
            }
        }

        #! First, loop through each configuration root directory
        :root foreach ($possibleRootPath in $Path) {
            #! Then, loop through each of the default names for a profile directory
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
    }
    end {
        $profileDirectory
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
