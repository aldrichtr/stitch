
begin {
    #-------------------------------------------------------------------------------
    #region Define aliases
    Write-Debug "`n<$('-' * 80)"

    Write-Debug 'Setting aliases for use in tasks'
    #TODO: I think I may move all of the Set-Alias commands here
    <#------------------------------------------------------------------
    This alias allows you to call another task from within another task
    without having to re-invoke invoke-build.  That way all of the state
    and properties is preserved.
    Example
    if ($config.Foo -eq 1) {call update_foo}
    #! it is definitely messing with the internals a bit which is not
    #! recommended
    ------------------------------------------------------------------#>
    Set-Alias -Name call -Value *Task -Description 'Call an Invoke-Build task from within another task'

    Set-Alias -Name phase -Value Add-BuildTask -Description 'Top level task associated with a development lifecycle phase'

    Write-Debug '  - Complete'
    Write-Debug "`n$('-' * 80)>"
    #endregion Define aliases
    #-------------------------------------------------------------------------------

    # Any errors that occur while loading build scripts will get collected here
    $script:errorMessage = @()

    #-------------------------------------------------------------------------------
    #region Load Stitch module

    Write-Debug "`n<$('-' * 80)"
    Write-Debug 'Ensure the stitch module is available'

    <#
    This allows us to load an alternate version of stitch for use in this build
    script. (For example, when developing the stitch module)
    Just import the stitch module you want to use prior to running Invoke-Build
    #>

    Write-Debug '  - Checking if Stitch is already loaded'
    $stitchModule = Get-Module Stitch -ErrorAction SilentlyContinue
    # Only load Stitch if it isn't already loaded.
    if ($null -eq $stitchModule) {
        Write-Debug '- Did not find the stitch module'
        try {
            Write-Debug '  - Attempting to load the stitch module'
            $stitchModule = Import-Module Stitch -NoClobber -ErrorAction Stop -PassThru
        } catch {
            throw "Could not import Stitch`n$_"
        }
    } else {
        Write-Debug "  - Version $($stitchModule.Version) loaded"
    }

    Write-Verbose "Using $($stitchModule.Version) of stitch"
    Write-Debug "Stitch loaded from $($stitchModule.Path)"
    Write-Debug "`n$('-' * 80)>"

    #endregion Load Stitch module
    #-------------------------------------------------------------------------------

    $BuildConfigPath = Find-BuildConfigurationDirectory -BuildProfile $BuildProfile
    #-------------------------------------------------------------------------------
    #region Load stitch config
    Write-Debug "`n<$('-' * 80)"
    Write-Debug 'Looking for stitch configuration file'
    if ($null -ne $BuildConfigPath) {
        $possibleStitchConfig = $BuildConfigPath | Find-StitchConfigurationFile
        if ($null -ne $possibleStitchConfig) {
            switch ($possibleStitchConfig.Count) {
                0 {
                    throw "No configuration file was found at $BuildConfigPath"
                    continue
                }
                1 {
                    Write-Debug "Using Configuration file $($possibleStitchConfig.FullName)"
                    $StitchConfigFile = $possibleStitchConfig
                    Remove-Variable possibleStitchConfig
                }
                default {
                    Write-Debug 'Multiple config files found!'
                    Write-Debug "Using Configuration file $($possibleStitchConfig[0].FullName)"
                    $StitchConfigFile = $possibleStitchConfig[0]
                    Remove-Variable possibleStitchConfig
                }
            }
            Write-Verbose "Stitch configuration file : $StitchConfigFile"
            . $StitchConfigFile
        }
    } else {

    }
    Write-Debug "`n$('-' * 80)>"
    #endregion Load stitch config
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Import Task Files
    Write-Debug "`n<$('-' * 80)"

    Write-Debug 'Loading task files'
    if (-not($SkipModuleTaskImport)) {
        $cmd = Get-Command 'Import-TaskFile' -ErrorAction SilentlyContinue
        if ($null -ne $cmd) {
            try {
                Write-Debug '  - Calling Import function'
                . Import-TaskFile
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        } else {
            Write-Error 'Task import not available in this version'
        }
    }
    Write-Debug '  - Complete'

    Write-Debug "`n$('-' * 80)>"
    #endregion Import Task Files
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Import Build Scripts

    Write-Debug 'Loading build scripts'
    if (-not($SkipModuleTaskImport)) {
        $cmd = Get-Command 'Import-BuildScript' -ErrorAction SilentlyContinue
        if ($null -ne $cmd) {
            try {
                Write-Debug '  - Calling Import function'
                . Import-BuildScript
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        } else {
            Write-Error 'Task import not available in this version'
        }
    }
    Write-Debug '  - Complete'

    #endregion Import Build Scripts
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Phase definitions

    if (Test-FeatureFlag 'phaseConfigFile') {
        if ($null -ne $BuildConfigPath) {
            $possiblePhasePath = (Join-Path $BuildConfigPath 'phases')
            if (Test-Path $possiblePhasePath) {
                Write-Debug "Loading phase definitions from $possiblePhasePath"
                $possiblePhasePath | Initialize-PhaseDefinition
            }
            Remove-Variable possiblePhasePath -ErrorAction 'SilentlyContinue'
        }
    } else {
        Write-Debug "'phaseConfigFile' feature disabled"
    }

    #endregion Phase definitions
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Load the runbook
    Write-Debug "`n<$('-' * 80)"


    $Runbook = $BuildConfigPath | Get-BuildRunBook

    if ($null -ne $Runbook) {
        if (Test-Path $Runbook) {
            Write-Debug "Importing runbook $Runbook"
            . $Runbook
            Write-Debug '  - Complete'
        }
    } else {
        Write-Debug "Runbook was not found, looking in BuildConfigPath"
        $foundRunbooks = Select-BuildRunBook -Path $BuildConfigPath
        foreach ($runbook in $foundRunbooks) {
            Write-Debug "Importing runbook $Runbook"
            . $Runbook
        }
        Write-Debug '  - Complete'
    }

    Write-Debug "`n$('-' * 80)>"
    #endregion Load the runbook
    #-------------------------------------------------------------------------------
}
process {
    Write-Debug "`n$('-' * 80)`n-- Process $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    <#------------------------------------------------------------------
      Add additional functionality here if needed
    ------------------------------------------------------------------#>
}
end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
}
