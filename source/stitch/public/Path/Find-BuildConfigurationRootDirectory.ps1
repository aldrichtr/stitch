
function Find-BuildConfigurationRootDirectory {
    <#
    .SYNOPSIS
        Find the build configuration root directory for this project
    .EXAMPLE
        Find-BuildConfigurationRootDirectory -Path $BuildRoot
    .EXAMPLE
        $BuildRoot | Find-BuildConfigurationRootDirectory
    .NOTES
        `Find-BuildConfigurationRootDirectory` looks in the current directory of the caller if no Path is given
    #>
    [OutputType([System.IO.DirectoryInfo])]
    [CmdletBinding()]
    param(
        # Specifies a path to a location to look for the build configuration root
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        #TODO: A good example of what would be in the module's (PoshCode) Configuration if we used it
        $possibleRoots = @(
            '.build',
            '.stitch'
        )
        $buildConfigRoot = $null
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            $Path = Get-Location
        }
        :path foreach ($possibleRootPath in $Path) {
            :root foreach ($possibleRoot in $possibleRoots) {
                $possiblePath =  (Join-Path $possibleRootPath $possibleRoot)
                if (Test-Path $possiblePath) {
                    $possiblePathItem = (Get-Item $possiblePath)
                    if ($possiblePathItem.PSIsContainer) {
                        $buildConfigRoot = $possiblePathItem
                    } else {
                        $buildConfigRoot = (Get-Item ($possiblePathItem | Split-Path -Parent))
                    }
                    Write-Debug "Found build configuration root directory 'buildConfigRoot'"
                    break path
                }
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        $buildConfigRoot
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
