
function Test-ProjectRoot {
    <#
    .SYNOPSIS
        Test if the given directory is the root directory of a project
    .DESCRIPTION
        `Test-ProjectRoot` looks for the build configuration file and directory
        `.build.ps1` and either `.stitch\` or `.build`
    .EXAMPLE
        Test-ProjectRoot

        Without a -Path, tests the current directory for default project directories
    .EXAMPLE
        $projectPath | Test-ProjectRoot
    .NOTES
        Defaults are:
        - Source : .\source
        - Staging : .\stage
        - Tests : .\tests
        - Artifact : .\out
        - Docs : .\docs

    #>
    [CmdletBinding()]
    param(
        # Optionally give a path to start in
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateScript(
            {
                if (-not($_ | Test-Path)) {
                    throw "$_ does not exist"
                }
                return $true
            }
        )]
        [Alias('PSPath')]
        [string]$Path = (Get-Location).ToString()
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $possibleRoots = @('.build', '.stitch')
    }
    process {
        $possibleBuildConfigRoot = $Path | Find-BuildConfigurationRootDirectory
        if ($null -ne $possibleBuildConfigRoot) {
            Write-Debug "Found build config root directory '$possibleBuildConfigRoot'"
            if ($possibleBuildConfigRoot.Name -in $possibleRoots) {
                Write-Debug "$($possibleBuildConfigRoot.Name) is a valid root"
                if (Get-ChildItem -Path $Path -Filter '.build.ps1') {
                    Write-Debug "Found build script"
                    $true | Write-Output
                } else {
                    Write-Debug "Did not find build script"
                    $false | Write-Output
                }
            } else {
                $false | Write-Output
            }
        } else {
            $false | Write-Output
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
