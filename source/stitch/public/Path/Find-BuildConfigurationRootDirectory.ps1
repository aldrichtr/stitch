
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
    [Alias('Resolve-BuildConfigurationRootDirectory')]
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
        $possibleRoots = @( '.build', '.stitch' )
        $configurationRootDirectory = $null
    }
    process {
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            $Path = Get-Location
        }
        #! if this function is called within a build script, then BuildConfigRoot should be set already
        $possibleBuildConfigRoot = $PSCmdlet.GetVariableValue('BuildConfigRoot')

        if ($null -ne $possibleBuildConfigRoot) {
            Write-Debug "Found `$BuildConfigRoot => $possibleBuildConfigRoot"
            $configurationRootDirectory = $possibleBuildConfigRoot
        } else {
            :path foreach ($possibleRootPath in $Path) {
                Write-Debug "Looking for a build configuration directory in $possibleRootPath"
                :root foreach ($possibleRoot in $possibleRoots) {
                    Write-Debug "  - Looking for $possibleRoot directory"
                    $possiblePath = (Join-Path $possibleRootPath $possibleRoot)
                    if (Test-Path $possiblePath) {
                        $possiblePathItem = (Get-Item $possiblePath)
                        if ($possiblePathItem.PSIsContainer) {
                            $configurationRootDirectory = $possiblePathItem
                        } else {
                            $configurationRootDirectory = (Get-Item ($possiblePathItem | Split-Path -Parent))
                        }
                        Write-Debug "    - Found build configuration root directory '$configurationRootDirectory'"
                        break path
                    }
                }
            }
        }
    }
    end {
        $configurationRootDirectory | Write-Output
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
