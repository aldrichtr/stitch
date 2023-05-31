
function Test-ProjectRoot {
    <#
    .SYNOPSIS
        Test if the given directory is the root directory of a project
    .DESCRIPTION
        `Test-ProjectRoot` looks for "typical" project directories in the given -Path and returns true if at least
        two of them exist.

        Typical project directories are:
        - A source directory (this may be controlled by the variable $Source)
        - A staging directory (the variable $Staging)
        - A tests directory (the variable $Tests)
        - A artifact/output directory (the variable $Artifact)
        - A documentation directory (the variable $Docs)
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
        [string]$Path = (Get-Location).ToString(),

        # Powershell Data File with defaults
        [Parameter(
        )]
        [string]$Defaults,

        # Default Source directory
        [Parameter(
        )]
        [string]$Source = '.\source',

        # Default Tests directory
        [Parameter(
        )]
        [string]$Tests = '.\tests',

        # Default Staging directory
        [Parameter(
        )]
        [string]$Staging = '.\stage',

        # Default Artifact directory
        [Parameter(
        )]
        [string]$Artifact = '.\out',

        # Default Docs directory
        [Parameter(
        )]
        [string]$Docs = '.\docs'
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        #! How many default directories must be present to be considered true
        $DEFAULTS_REQUIRED = 2

        $FAILSAFE_DEFAULTS = @{
            Source   = $Source
            Tests    = $Tests
            Staging  = $Staging
            Artifact = $Artifact
            Docs     = $Docs
        }

        if ($PSBoundParameters.ContainsKey('Defaults')) {
            if (Test-Path $Defaults) {
                Write-Debug "Importing defaults from $Defaults"
                $defaultFolders = Import-PowerShellDataFile $Defaults
            }
        } else {
            Write-Debug 'No defaults file found using internal defaults'
            $defaultFolders = $FAILSAFE_DEFAULTS
        }
        Write-Debug "Default Folders are:"
        foreach ($key in $defaultFolders.Keys) {
            Write-Debug ("  - {0,-16} => {1}" -f $key, $defaultFolders[$key])
        }
    }
    process {
        Write-Debug "Testing against default project directories in $Path"
        $defaultsInDirectory = 0
        foreach ($key in $defaultFolders.Keys) {
            Write-Debug "Checking for $key variable. Defaults found so far $defaultsInDirectory"
            $pathVariable = Get-Variable $key -ValueOnly -ErrorAction SilentlyContinue
            Write-Debug "  - The path we are looking for is $pathVariable"
            if ($null -ne $pathVariable) {
                if ([system.io.path]::IsPathFullyQualified($pathVariable)) {
                    Write-Debug "  - found $pathVariable fully qualified"
                    $pathToTest = $pathVariable
                } else {
                    $pathToTest = (Join-Path $Path $pathVariable)
                }
            } else {
                throw "No value given for `$$key"
            }

            Write-Debug "Testing if $pathToTest is present"
            if (Test-Path $pathToTest) {
                Write-Debug '  - It was found'
                $defaultsInDirectory += 1
            } else {
                Write-Debug '  - It was NOT found'
            }
        }
    }
    end {
        Write-Debug "$defaultsInDirectory found $DEFAULTS_REQUIRED needed to pass"
        $defaultsInDirectory -ge $DEFAULTS_REQUIRED | Write-Output

        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
