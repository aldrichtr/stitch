
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
        [string]$Path = (Get-Location).ToString()
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        #! How many default directories must be present to be considered true
        $DEFAULTS_REQUIRED = 2

        $defaultsFile = (Join-Path $MyInvocation.MyCommand.Module.ModuleBase 'Defaults.psd1')
        $defaults = Import-Psd $defaultsFile
    }
    process {
        Write-Debug 'Testing against default project directories'
        $defaultsInDirectory = 0
        foreach ($key in $defaults.Keys) {
            Write-Debug "Checking for $key variable. Defaults found so far $defaultsInDirectory"
            $pathVariable = Get-Variable $key -ValueOnly -ErrorAction SilentlyContinue
            if ($null -ne $pathVariable) {
                $pathToTest = $pathVariable
            } else {
                $pathToTest = (Join-Path $Path $defaults[$key])
            }

            Write-Debug "Testing if $pathToTest is present"
            if (Test-Path $pathToTest) {
                $defaultsInDirectory += 1
            }
        }
    }
    end {
        Write-Debug "$defaultsInDirectory found $DEFAULTS_REQUIRED needed to pass"
        $defaultsInDirectory -ge $DEFAULTS_REQUIRED | Write-Output

        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
