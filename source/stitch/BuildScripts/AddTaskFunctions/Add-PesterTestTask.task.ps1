
Set-Alias pester Add-PesterTestTask

function Add-PesterTestTask {
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory
        )]
        [string]$Name,

        # The type of tests to run.  Tests should be organized by type in folders under
        # the tests directory.  Defaults to 'Unit'
        [Parameter(
        )]
        [string]$Type = 'Unit',

        # The type of output pester should show
        [Parameter(
        )]
        [ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
        [string]$Output = 'Detailed',

        # Generate code coverage metrics
        [Parameter(
        )]
        [switch]$CodeCov,

        # A psd1 configuration file in PesterConfiguration format
        [Parameter(
        )]
        [string]$ConfigurationFile,

        # Do not produce an error code if tests fail
        [Parameter(
        )]
        [switch]$NoErrorOnFail
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $DEFAULT_CONFIG_FILE = (Join-Path $BuildConfigPath "pester.$Type.config.psd1")
    }
    process {
        if ($PSBoundParameters.ContainsKey('ConfigurationFile')) {
            if (-not(Test-Path $ConfigurationFile)) {
                throw "Pester configuration file '$ConfigurationFile' could not be found"
            }
        } elseif (Test-Path $DEFAULT_CONFIG_FILE ) {
            $ConfigurationFile = $DEFAULT_CONFIG_FILE
        }

        #region Generate task
        Add-BuildTask $Name -Data $PSBoundParameters -Source $MyInvocation {
            if (-not($Task.Data.ContainsKey('Type'))) {
                $Task.Data['Type'] = 'Unit'
            }

            if ($Task.Data.ContainsKey('ConfigurationFile')) {
                logInfo "Pester configuration using '$($Task.Data.ConfigurationFile)'"
                $pesterOptions = Import-Psd $Task.Data.ConfigurationFile
            } else {
                if (Test-Path (Join-Path (property Tests) $Task.Data.Type)) {
                    $pesterOptions = @{
                        Run = @{
                            Path = (Join-Path (property Tests) $Task.Data.Type)
                        }
                    }
                } else {
                    $pesterOptions = @{
                        Run = @{
                            Path = (property Tests)
                        }
                    }
                }
                if (-not($NoErrorOnFail)) {
                    $pesterOptions.Run['Exit'] = $true
                }
            }
            if ($CodeCov) {
                $pesterOptions['CodeCoverage'] = @{
                    Enabled      = $true
                    OutputFormat = 'JaCoCo'
                    OutputPath   = (Join-Path $Artifact "tests/pester.$Type.codecov.jacoco.xml")
                    Path         = @(
                        $Source
                    )
                    RecursePaths = $true
                }

                if ([string]::IsNullOrEmpty($CodeCovFormat)) {
                    $CodeCovFormat = 'JaCoCo'
                    $pesterOptions.CodeCoverage.OutputFormat = 'JaCoCo'
                }

                if ([string]::IsNullOrEmpty($CodeCovPath)) {
                    $CodeCovPath = ($CodeCovPath -replace [regex]::Escape('{Type}') , $Task.Data.Type)
                    $CodeCovPath = ($CodeCovPath -replace [regex]::Escape('{Format}') , $CodeCovFormat)
                    if (-not(Test-Path $CodeCovPath)) {
                        try {
                            New-Item $CodeCovPath -ItemType Directory -Force
                            logInfo "Created non-existant directory '$(Resolve-Path $CodeCovPath -Relative)'"
                        } catch {
                            throw (logError "Could not create Code Coverage Path '$CodeCovPath'`n$_" -Passthru)
                        }
                    }
                    $pesterOptions.CodeCoverage.OutputPath
                }


            }
            #! Output is set in this order (last setting wins):
            #! 1. Config file
            #! 2. Output parameter to Add-PesterTestTask
            #! 3. PesterOutput parameter

            if ($Task.Data.ContainsKey('Output')) {
                logDebug "Pester Output set to '$($Task.Data.Output)' by task parameter -Output"
                if (-not($pesterOptions.ContainsKey('Output'))) {
                    $pesterOptions['Output'] = @{}
                }
                $pesterOptions.Output['Verbosity'] = $Task.Data.Output
            }

            if ($null -ne $PesterOutput) {
                logDebug "Pester Output set to '$PesterOutput' by parameter -PesterOutput"
                $pesterOptions.Output['Verbosity'] = $PesterOutput
            }

            logDebug "Running Pester tests in '$($pesterOptions.Run.Path)'"
            $config = New-PesterConfiguration -Hashtable $pesterOptions
            Invoke-Pester -Configuration $config
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
