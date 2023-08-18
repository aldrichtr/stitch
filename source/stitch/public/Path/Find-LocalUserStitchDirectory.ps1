
function Find-LocalUserStitchDirectory {
    <#
    .SYNOPSIS
        Find the directory in the users home directory that contains stitch configuration items
    #>
    [Alias('Resolve-LocalUserStitchDirectory')]
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations to look for the users local stitch directory
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
        $possibleRootDirectories = @(
            $env:USERPROFILE,
            $env:HOME,
            $env:LOCALAPPDATA,
            $env:APPDATA
        )

        $possibleStitchDirectories = @(
            '.stitch'
        )

        $userStitchDirectory = $null
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            $Path = $possibleRootDirectories
        }
        #! We only need to search the 'possibleRootDirectories' if a Path was not given
        :root foreach ($possibleRootDirectory in $Path) {
            :stitch foreach ($possibleStitchDirectory in $possibleStitchDirectories) {
                if  ((-not ([string]::IsNullorEmpty($possibleRootDirectory))) -and
                     (-not ([string]::IsNullorEmpty($possibleStitchDirectory)))) {

                    $possiblePath = (Join-Path $possibleRootDirectory $possibleStitchDirectory)
                        if (Test-Path $possiblePath) {
                            $possiblePathItem = (Get-Item $possiblePath)
                            if ($possiblePathItem.PSIsContainer) {
                                $userStitchDirectory = $possiblePath
                            } else {
                                $userStitchDirectory = $possiblePath | Split-Path -Parent
                            }
                        Write-Debug "Local user stitch directory found at $userStitchDirectory"
                        break root
                    }
                }
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        $userStitchDirectory
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
