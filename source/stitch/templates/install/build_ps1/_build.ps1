
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

    Write-Debug "Stitch loaded from $($stitchModule.Path)"
    Write-Debug "`n$('-' * 80)>"

    #endregion Load Stitch module
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region set BuildConfigPath
    Write-Debug "`n<$('-' * 80)"

    <#
     Here we need to ensure that at the least, we have found a useable build configuration root directory
    `$BuildConfigRoot`  This could be one of a few directories under Invoke-Build's `$BuildRoot`
    #>


    <#
    We will drill down from StartingDirectory -> Build Configuration Root -> Profile Root -> Current Profile
    We are going to try to find the build configuration path.  This relies on either
    the ProfilePath or BuildConfigRoot being set to a valid path.
    #>
    $buildRootIsSet = (-not ([string]::IsNullorEmpty($BuildRoot)))
    #-------------------------------------------------------------------------------
    #region Starting Directory

    Write-Debug 'Resolving the starting directory'
    $startingDirectory = Resolve-ProjectRoot -ErrorAction SilentlyContinue
    if ($null -eq $startingDirectory) {
        if ($buildRootIsSet) {
            Write-Debug "- BuildRoot was set. Looking in $BuildRoot"
            $startingDirectory = $BuildRoot
        } else {
            $startingDirectory = (Get-Location).Path
            Write-Debug '- BuildRoot was not set. Using current directory'
        }
    } else {
        Write-Debug '- Resolved Project Root'
    }

    # abort if we can't find the starting directory
    if ($null -eq $startingDirectory) {
        throw 'Something went wrong, could not determine starting directory'
    } else {
        Write-Verbose "Starting in $startingDirectory"
    }

    #endregion Starting Directory
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Build Configuration Root
    $buildConfigRootIsSet = (-not ([string]::IsNullorEmpty($BuildConfigRoot)))

    Write-Debug 'Resolving the Build Configuration Root Directory'
    if ($buildConfigRootIsSet) {
        Write-Debug "- BuildConfigRoot was set to '$BuildConfigRoot' by Parameters"
    } else {
        # Now that we have a starting point, see if we can find the BuildConfigRoot
        $possibleBuildConfigRoot = ($startingDirectory | Find-BuildConfigurationRootDirectory -Debug)
        Write-Debug "- found BuildConfigRoot in '$possibleBuildConfigRoot'"
        if ($null -ne $possibleBuildConfigRoot) {
            $BuildConfigRoot = $possibleBuildConfigRoot
            Write-Debug "- BuildConfigRoot is a $($BuildConfigRoot.GetType().FullName)"
            Write-Debug "- BuildConfigRoot is now set to '$BuildConfigRoot'"
            Remove-Variable possibleBuildConfigRoot -ErrorAction SilentlyContinue
        }
    }

    #! abort if we cannot find the Build Configuration Root
    if ($null -eq $BuildConfigRoot) {
        throw 'Could not find the Build Configuration Root Directory (.build or .stitch by default)'
    } elseif (-not (Test-Path $BuildConfigRoot)) {
        throw "BuildConfigRoot points to an invalid path '$BuildConfigRoot'"
    }
    #endregion Build Configuration Root
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Profile path


    # if we made it here, then BuildConfigRoot is a valid path
    # the best option is that $ProfilePath and $BuildProfile are set and that results in a valid path

    # the next option is that $ProfilePath is set, and $DefaultBuildProfile are set and valid

    # ProfilePath isn't set, we use BuildConfigRoot to look for runbooks

    if ([string]::IsNullorEmpty($ProfilePath)) {
        Write-Debug 'ProfilePath was not set.  Looking for a profile path'

        $possibleProfileRoot = $BuildConfigRoot | Find-BuildProfileRootDirectory

        if ($null -ne $possibleProfileRoot) {
            Write-Debug "- Found profile root directory '$possibleProfileRoot'"
            $ProfilePath = $possibleProfileRoot
        }
        Remove-Variable possibleProfileRoot -ErrorAction SilentlyContinue
        Write-Verbose "ProfilePath set to $ProfilePath"
    }

    # Either it was already set or we just found the ProfilePath
    if ([string]::IsNullorEmpty($ProfilePath)) {
        if (Test-Path $ProfilePath) {
            Write-Debug "ProfilePath was set to $ProfilePath by parameter"
            if (-not ([string]::IsNullorEmpty($BuildProfile))) {
                $BuildConfigPath = (Join-Path $ProfilePath $BuildProfile)
            } elseif (-not ([string]::IsNullorEmpty($DefaultBuildProfile))) {
                $BuildConfigPath = (Join-Path $ProfilePath $DefaultBuildProfile)
            } else {
                $foundRunbooks = Select-BuildRunBook -Path $ProfilePath
                if ($null -ne $foundRunbooks) {
                    $BuildConfigPath = Split-Path -Path $foundRunbooks -Parent
                    Write-Verbose "No Profiles were set, but found runbook in $ProfilePath"
                }
            }
        } else {
            throw "ProfilePath was set to an invalid path '$ProfilePath'"
        }
    }
    #endregion Profile path
    #-------------------------------------------------------------------------------

    if ([string]::IsNullorEmpty($BuildConfigPath)) {
        # we didn't find a valid configurtion path yet, see if we can find a runbook in the config root

        #! it shouldn't be possible to get here without it, but let's make sure
        if ($null -ne $BuildConfigRoot) {
            if (Test-Path $BuildConfigRoot) {
                $runbookOptions = @{
                    Path = $BuildConfigRoot
                }
                if (-not ([string]::IsNullorEmpty($BuildProfile))) {
                    $runbookOptions['BuildProfile'] = $BuildProfile
                } elseif (-not ([string]::IsNullorEmpty($DefaultBuildProfile))) {
                    $runbookOptions['BuildProfile'] = $DefaultBuildProfile
                }
                $foundRunbooks = Select-BuildRunBook -Path $ProfilePath
                if ($null -ne $foundRunbooks) {
                    $BuildConfigPath = Split-Path -Path $foundRunbooks -Parent
                    $Runbook = $foundRunbooks
                    Write-Verbose "A Runbook was found in '$BuildConfigRoot'"
                }
            } else {
                throw "Build Configuration Root was set to an invalid path '$BuildConfigRoot'"
            }
        }
    }

    Remove-Variable runbookOptions, foundRunbooks -ErrorAction SilentlyContinue

    <#
    All of this was to set BuildConfigPath.  If we made it here and it still isnt set, we are in big trouble, we should
    just quit and let the user know why
    #>
    if ($null -eq $BuildConfigPath) {
        if ($errorMessage.Count -gt 0) {
            throw ($errorMessage -join "`n")
        } else {
            throw "**Can't continue** Could not find the build configuration path"
        }
    } else {
        Write-Verbose "Build configuration Path : $BuildConfigPath"
    }
    Write-Debug "`n$('-' * 80)>"
    #endregion set BuildConfigPath
    #-------------------------------------------------------------------------------

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
        if ($errorMessage.Count -gt 0) {
            throw ( $errorMessage -join "`n")
        }
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

    if ($null -ne $Runbook) {
        if (Test-Path $Runbook) {
            Write-Debug "Importing runbook $Runbook"
            . $Runbook
            Write-Debug '  - Complete'
        }
    } else {
        Write-Debug "Runbook was not set, looking in BuildConfigPath"
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
