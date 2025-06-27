
$options = @{
    Name        = 'pester'
    Value       = 'Add-PesterTestTask'
    Description = 'Run Pester tests with the given configuration or defaults'
    Scope       = 'Script'
}

Set-Alias @options
Remove-Variable options -ErrorAction SilentlyContinue
function Add-PesterTestTask {
    [CmdletBinding()]
    param(
        # The name of the Invoke-Build Task
        [Parameter(
            Position = 0,
            Mandatory
        )]
        [string]$Name,

        # The type of tests to run.  Tests should be organized by type in folders under
        # the tests directory.  Defaults to 'Unit'
        [Parameter(
        )]
        [string]$Type,

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
        $DEFAULT_TEST_TYPE = 'UNIT'

        #! Explicitly set Type if it wasn't given
        if (-not ($PSBoundParameters.ContainsKey('Type'))) {
            $PSBoundParameters.Add('Type', $DEFAULT_TEST_TYPE)
        }

        #-------------------------------------------------------------------------------
        #region Configuration file

        <#
         TODO: Document the default pester config file
         If no configuration file was given, then attempt to find $BuildConfigPath/pester/*<Type>*.config.psd1
        #>
        if (-not ($PSBoundParameters.ContainsKey('ConfigurationFile'))) {
            if (-not ([string]::IsNullorEmpty($BuildConfigPath))) {
                $possiblePesterDirectory = Get-ChildItem $BuildConfigPath -Filter 'pester' -Directory
                if ($null -ne $possiblePesterDirectory) {
                    $options = @{
                        #! if no Type was given, it defaults to 'Unit'
                        Filter = "*$Type*.config.psd1"
                        Path   = $possiblePesterDirectory
                    }

                    $possibleConfigurationFile = Get-ChildItem @options |
                        Select-Object -First 1

                    if ($null -ne $possibleConfigurationFile) {
                        $PSBoundParameters['ConfigurationFile'] = $possibleConfigurationFile
                    }
                }
            }
        }

        #endregion Configuration file
        #-------------------------------------------------------------------------------
    }
    process {

        Add-BuildTask $Name -Data $PSBoundParameters -Source $MyInvocation {
            $DEFAULT_CODECOV_FORMAT = 'JaCoCo'
            $DEFAULT_CODECOV_FILE = 'pester.codecoverage.xml'
            $DEFAULT_OUTPUT_VERBOSITY = 'Detailed'
            $DEFAULT_TEST_RESULT_FORMAT = 'NUnitXml'
            $DEFAULT_TEST_RESULT_FILE = 'test.result.xml'
            $DEFAULT_PESTER_RESULT_FILE = 'pester.result.clixml'

            $pesterOptions = @{}

            logDebug "Running $($Task.Data.Type) pester tests"

            #-------------------------------------------------------------------------------
            #region Run Path

            if ($Task.Data.ContainsKey('ConfigurationFile')) {
                try {
                    logDebug "Attempting to load $($Task.Data.ConfigurationFile)"
                    $pesterOptions = Import-Psd $Task.Data.ConfigurationFile -Unsafe
                    logInfo "Pester configured using '$($Task.Data.ConfigurationFile)'"
                } catch {
                    throw (logError "Could not load $($Task.Data.ConfigurationFile)" -PassThru)
                }
                # If it was loaded then at a minimum, the path needs to be valid first
                if (-not [string]::IsNullorEmpty($pesterOptions.Run.Path)) {
                    if (-not (Test-Path $pesterOptions.Run.Path)) {
                        throw "$($pesterOptions.Run.Path) specified in $($Task.Data.ConfigurationFile) is not a valid path"
                    }
                }
            } else {
                # Set some defaults
                logInfo "No configuration file was given for ($Task.Name)"
                logDebug 'Looking for a path to the Tests'
                $possibleTestsPath = (Join-Path (Get-BuildProperty Tests) $Task.Data.Type)
                if (Test-Path $possibleTestsPath) {
                    logDebug "- Found $($Task.Data.Type) tests path '$possibleTestsPath'"
                    $pesterOptions = @{
                        Run = @{
                            Path = $possibleTestsPath
                        }
                    }
                } elseif (-not ([string]::IsNullorEmpty((Get-BuildProperty Tests)))) {
                    logDebug "- $possibleTestPath does not exist.  Found tests path $(Get-BuildProperty Tests)"
                    $pesterOptions = @{
                        Run = @{
                            Path = (Get-BuildProperty Tests)
                        }
                    }
                } else {
                    $currentDirectory = Get-Location
                    logInfo "- Could not determine Pester test path using '$currentDirectory'"
                    $pesterOptions = @{
                        Run = @{
                            Path = $currentDirectory
                        }
                    }

                }

            }

            #endregion Run Path
            #-------------------------------------------------------------------------------

            #-------------------------------------------------------------------------------
            #region Exit code

            if (-not($NoErrorOnFail)) {
                $pesterOptions.Run['Exit'] = $true
            }

            #endregion Exit code
            #-------------------------------------------------------------------------------

            #-------------------------------------------------------------------------------
            #region Code coverage

            #! If the key exists, and is set return that.  Otherwise return false
            if (-not ([string]::IsNullorEmpty($pesterOptions.CodeCoverage.Enabled))) {
                $codeCovSetByConfigFile = $pesterOptions.CodeCoverage.Enabled
            } else {
                $codeCovSetByConfigFile = $false
            }

            <#
             Code coverage is determined in one of three ways:
              1. The -CodeCov parameter to this function
              2. The -CodeCov parameter to Invoke-Build
              3. Set to $true in the file passed to -ConfigurationFile
            #>
            if (($Task.Data.CodeCov) -or (Get-BuildProperty CodeCov) -or ($codeCovSetByConfigFile)) {

                #region Enabled
                logInfo 'Code coverage is enabled'
                if (-not ($pesterOptions.ContainsKey('CodeCoverage'))) {
                    logDebug 'No CodeCoverage options exist. Creating key'
                    $pesterOptions['CodeCoverage'] = @{
                        Enabled = $true
                    }
                } else {
                    $pesterOptions.CodeCoverage['Enabled'] = $true
                }
                #endregion Enabled

                #region OutputFormat

                # If -CodeCovFormat was set, use that
                # elseif it is already set in the config use that
                # else use $DEFAULT_CODECOV_FORMAT
                $possibleCodeCovFormat = (Get-BuildProperty CodeCovFormat)
                if (-not ([string]::IsNullOrEmpty($possibleCodeCovFormat))) {
                    logDebug "CodeCovFormat set to '$possibleCodeCovFormat'"
                    $pesterOptions.CodeCoverage['OutputFormat'] = $possibleCodeCovFormat
                } elseif  (-not ([string]::IsNullOrEmpty($pesterOptions.CodeCoverage.OutputFormat))) {
                    logDebug "CodeCoverage.OutputFormat set to $($pesterOptions.CodeCoverage.OutputFormat) in config file"
                } else {
                    logInfo "No code coverage format specified. Using $DEFAULT_CODECOV_FORMAT"
                    $pesterOptions.CodeCoverage['OutputFormat'] = $DEFAULT_CODECOV_FORMAT
                }
                #endregion OutputFormat


                #region OutputPath
                #region Directory
                if ([string]::IsNullOrEmpty($CodeCovDirectory)) {
                    logInfo 'No CodeCovDirectory was set'
                    $possibleCodeCovDirectory = (Get-BuildProperty Artifact)
                    if (-not ([string]::IsNullorEmpty($possibleCodeCovDirectory))) {
                        logDebug "- Setting code coverage directory to `$Artifact"
                        $CodeCovDirectory = $possibleCodeCovDirectory
                    } else {
                        logDebug '- Setting code coverage directory to current directory'
                        $CodeCovDirectory = Get-Location
                    }
                }
                #endregion Directory

                #region File
                if ($CodeCovDirectory | Confirm-Path) {
                    if (-not ([string]::IsNullorEmpty($CodeCovFile))) {
                        logDebug '- CodeCovFile was set'
                        # in the stitch config, the user can use "tokens" for Type and Format in the file name
                        $CodeCovFile = ($CodeCovFile -replace [regex]::Escape('{Type}') , $Task.Data.Type.ToLower())
                        $CodeCovFile = ($CodeCovFile -replace [regex]::Escape('{Format}') , $CodeCovFormat.ToLower())
                    } else {
                        logDebug "- CodeCovFile was not set using default '$DEFAULT_CODECOV_FILE'"
                        $codeCovFile = $DEFAULT_CODECOV_FILE
                    }
                }
                #endregion File

                $codeCovPath = (Join-Path $CodeCovDirectory $CodeCovFile)
                logInfo "Writing Code Coverage to $codeCovPath"
                $pesterOptions.CodeCoverage.OutputPath = $codeCovPath
            }
            #endregion OutputPath

            #region Source Path
            if ([string]::IsNullorEmpty($pesterOptions.CodeCoverage.Path)) {
                logInfo 'CodeCoverage source path is not set'
                $possibleSourcePath = (Get-BuildProperty Source)
                if (-not ([string]::IsNullorEmpty($possibleSourcePath))) {
                    logInfo "- Setting source path to $possibleSourcePath"
                    $pesterOptions.CodeCoverage['Path'] = $possibleSourcePath
                }
            }

            if ([string]::IsNullorEmpty($pesterOptions.CodeCoverage.RecursePaths)) {
                $pesterOptions.CodeCoverage['RecursePaths'] = $true
            }
            #endregion Source Path

            #endregion Code coverage
            #-------------------------------------------------------------------------------


            #-------------------------------------------------------------------------------
            #region Test result
            if ((-not ([string]::IsNullOrEmpty($TestResultDirectory))) -or
                (-not ([string]::IsNullOrEmpty($TestResultFile)))) {
                if (-not ($pesterOptions.ContainsKey('TestResult'))) {
                    $pesterOptions['TestResult'] = @{}
                }
                $pesterOptions.TestResult['Enabled'] = $true

                #region OutputFormat
                $possibleTestResultFormat = (Get-BuildProperty TestResultFormat)
                if (-not ([string]::IsNullOrEmpty($possibleTestResultFormat))) {
                    logDebug "TestresultFormat set to '$possibleTestResultFormat'"
                    $TestResultFormat = $possibleTestResultFormat
                } elseif  (-not ([string]::IsNullOrEmpty($pesterOptions.TestResult.OutputFormat))) {
                    $TestResultFormat = $pesterOptions.TestResult.OutputFormat
                    logDebug "TestResult.OutputFormat set to $($pesterOptions.TestResult.OutputFormat) in config file"
                } else {
                    logInfo "No test result format specified. Using $DEFAULT_TEST_RESULT_FORMAT"
                    $TestResultFormat = $DEFAULT_TEST_RESULT_FORMAT
                }

                $pesterOptions.TestResult['OutputFormat'] = $TestResultFormat
                #endregion OutputFormat

                #region Directory
                if ([string]::IsNullOrEmpty($TestResultDirectory)) {
                    logInfo 'No TestResultDirectory was set'
                    $possibleTestResultDirectory = (Get-BuildProperty Artifact)
                    if (-not ([string]::IsNullorEmpty($possibleTestResultDirectory))) {
                        logDebug "- Setting test result directory to `$Artifact"
                        $TestResultDirectory = $possibleTestResultDirectory
                    } else {
                        logDebug '- Setting test result directory to current directory'
                        $TestResultDirectory = Get-Location
                    }
                }
                #endregion Directory

                #region File
                if ($TestResultDirectory | Confirm-Path) {
                    if (-not ([string]::IsNullorEmpty($TestResultFile))) {
                        logDebug '- TestResultFile was set'
                        # in the stitch config, the user can use "tokens" for Type and Format in the file name
                        $TestResultFile = ($TestResultFile -replace [regex]::Escape('{Type}') , $Task.Data.Type.ToLower())
                        $TestResultFile = ($TestResultFile -replace [regex]::Escape('{Format}') , $TestResultFormat.ToLower())
                    } else {
                        logDebug "- TestResultFile was not set using default '$DEFAULT_TEST_RESULT_FILE'"
                        $TestResultFile = $DEFAULT_TEST_RESULT_FILE
                    }
                }
                #endregion File

                $testResultPath = (Join-Path $TestResultDirectory $TestResultFile)
                logInfo "Writing Pester test results to $testResultPath"
                $pesterOptions.TestResult.OutputPath = $testResultPath
            }

            #endregion Test result
            #-------------------------------------------------------------------------------

            #-------------------------------------------------------------------------------
            #region Output

            #! Output is set by:
            #! if Output parameter to Add-PesterTestTask
            #! elseif PesterOutput parameter
            #! elseif Config file
            #! else $DEFAULT_OUTPUT_VERBOSITY

            if (-not($pesterOptions.ContainsKey('Output'))) {
                $pesterOptions['Output'] = @{}
            }

            if (-not ([string]::IsNullorEmpty($Task.Data.Output))) {
                logDebug "Pester Output set to '$($Task.Data.Output)' by task parameter -Output"
                $pesterOptions.Output['Verbosity'] = $Task.Data.Output
            } elseif (-not ([string]::IsNullOrEmpty((Get-BuildProperty PesterOutput)))) {
                logDebug "Pester Output set to '$(Get-BuildProperty PesterOutput)' by parameter -PesterOutput"
                $pesterOptions.Output['Verbosity'] = (Get-BuildProperty PesterOutput)
            } else {
                logInfo "Output verbosity not set.  Using default $DEFAULT_OUTPUT_VERBOSITY"
                $pesterOptions.Output['Verbosity'] = $DEFAULT_OUTPUT_VERBOSITY
            }

            #endregion Output
            #-------------------------------------------------------------------------------

            #-------------------------------------------------------------------------------
            #region Pester result

            if ((-not ([string]::IsNullOrEmpty($PesterResultDirectory))) -or
                (-not ([string]::IsNullOrEmpty($PesterResultFile)))) {
                $pesterOptions.Run.PassThru = $true
                #region Directory
                if ([string]::IsNullOrEmpty($PesterResultDirectory)) {
                    logInfo 'No PesterResultDirectory was set'
                    $possiblePesterResultDirectory = (Get-BuildProperty Artifact)
                    if (-not ([string]::IsNullorEmpty($possiblePesterResultDirectory))) {
                        logDebug "- Setting Pester result directory to `$Artifact"
                        $PesterResultDirectory = $possiblePesterResultDirectory
                    } else {
                        logDebug '- Setting Pester result directory to current directory'
                        $PesterResultDirectory = Get-Location
                    }
                }
                #endregion Directory

                #region File
                if ($PesterResultDirectory | Confirm-Path) {
                    if (-not ([string]::IsNullorEmpty($PesterResultFile))) {
                        logDebug '- PesterResultFile was set'
                        # in the stitch config, the user can use "tokens" for Type and Format in the file name
                        $PesterResultFile = ($PesterResultFile -replace [regex]::Escape('{Type}') , $Task.Data.Type.ToLower())
                    } else {
                        logDebug "- PesterResultFile was not set using default '$DEFAULT_PESTER_RESULT_FILE'"
                        $PesterResultFile = $DEFAULT_PESTER_RESULT_FILE
                    }
                }
                #endregion File

                $pesterResultPath = (Join-Path $PesterResultDirectory $PesterResultFile)
                logInfo "Writing Pester test results to $pesterResultPath"

            }

            #endregion Pester result
            #-------------------------------------------------------------------------------

            logInfo 'Configuration complete. Running Pester'
            try {
                $pesterResult = Invoke-Pester -Configuration (New-PesterConfiguration -Hashtable $pesterOptions)
                if ($pesterResult.Result -ne 'Passed') {
                    assert($null -ne $pesterResult) 'No PesterResult object was returned'
                }
            } catch {
                throw "There was an error running Pester tests`n$_"
            }


            logInfo 'Pester tests complete'

            if ($null -ne $pesterResultPath) {
                $pesterResult | Export-Clixml $pesterResultPath
                logInfo "Pester Test result saved to $pesterResultPath"
            }

        }
        Remove-Variable pesterConfig, pesterResult, pesterOptions -ErrorAction SilentlyContinue
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
