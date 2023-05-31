
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

    #-------------------------------------------------------------------------------
    #region Load Stitch module

    Write-Debug "`n<$('-' * 80)"
    Write-Debug 'Attempting to load the stitch module'
    $stitchModule = Get-Module Stitch
    Write-Debug '  - Checking if Stitch is already loaded'
    # Only load Stitch if it isn't already loaded.
    if ($null -eq $stitchModule) {
        Write-Debug 'Did not find the stitch module'
        try {
            Write-Debug '  - Attempting to load the stitch module'
            Import-Module Stitch -NoClobber -ErrorAction Stop
        } catch {
            Write-Error "Could not import Stitch`n$_"
        }
    } else {
        Write-Debug "  - Version $($stitchModule.Version) already loaded"
    }

    Write-Debug "Stitch loaded from $(Get-Module Stitch | Select-Object -ExpandProperty Path)"
    Write-Debug "`n$('-' * 80)>"

    #endregion Load Stitch module
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region set BuildConfigPath
    Write-Debug "`n<$('-' * 80)"

    <#
    #TODO: Either hide or remove $BuildConfigPath as a Parameter.  It should be "dynamic" based on other settings

    #TODO: ProfilePattern can be removed, we are "standardizing" on *runbook.ps1 (and it was moved to a function)


    Here we need to ensure that at the least, we have found a useable build configuration root directory
    `$BuildConfigRoot`  This could be one of a few directories under Invoke-Build`s `$BuildRoot`

    #>

    $script:errorMessage = @()

    <#
    We are going to try to find the build configuration path.  This relies on either
    the ProfilePath or BuildConfigRoot being set to a valid path.
    #>
    $buildRootIsNotSet = ([string]::IsNullorEmpty($BuildRoot))
    $buildConfigRootIsNotSet = ([string]::IsNullorEmpty($BuildConfigRoot))
    $profilePathIsNotSet = ([string]::IsNullorEmpty($ProfilePath))

    if ($profilePathIsNotSet) {
        Write-Debug "ProfilePath was not set.  Looking for a profile path"
        #-------------------------------------------------------------------------------
        #region Set BuildConfigRoot

        # "Walk" our way up from either BuildRoot or the Current Location
        if ($buildConfigRootIsNotSet) {
            Write-Debug "  - BuildConfigRoot was not set.  Looking for a build directory"
            if ($buildRootIsNotSet) {
                $startingDirectory = (Get-Location)
                Write-Debug "    - BuildRoot was not set.  Looking in current directory"
            } else {
                # BuildRoot is set
                Write-Debug "    - BuildRoot was set. Looking in $BuildRoot"
                $startingDirectory = $BuildRoot
            }

            # Now that we have a starting point, see if we can find the BuildConfigRoot
            $possibleBuildConfigRoot = $startingDirectory | Find-BuildConfigurationRootDirectory
            if ($null -ne $possibleBuildConfigRoot) {
                $BuildConfigRoot = $possibleBuildConfigRoot
                Write-Debug "    - BuildConfigRoot is now set to '$BuildConfigRoot'"
                Remove-Variable possibleBuildConfigRoot -ErrorAction SilentlyContinue
            }
        } else {
            Write-Debug "  - BuildConfigRoot already set to '$BuildConfigRoot'"
        }
        #endregion Set BuildConfigRoot
        #-------------------------------------------------------------------------------

        Write-Verbose "Build configuration root: '$BuildConfigRoot'"
        # Now that BuildConfigRoot is set, we want to find the Profile path
        Write-Debug "  - Looking for the profile path"
        $possibleProfileRoot = $BuildConfigRoot | Find-BuildProfileRootDirectory

        if ($null -ne $possibleProfileRoot) {
            Write-Debug "    - Found profile directory '$possibleProfileRoot'"
            $ProfilePath = $possibleProfileRoot
            $options = @{
                Path = $ProfilePath
            }
        } else {
            $options = @{
                Path = $BuildConfigRoot
            }
            # there are no profile directories, maybe its just the runbook and config file
            # here in BuildconfigRoot ?
        }
        Remove-Variable possibleProfileRoot -ErrorAction SilentlyContinue

        if (-not ([string]::IsNullorEmpty($BuildProfile))) {
            $options['BuildProfile'] = $BuildProfile
        }
        Write-Debug "    - Looking for BuildConfigPath in $($options.Path) $($BuildProfile ?? 'no build profile set')"
        $possibleRunBook = Select-BuildRunBook @options

        if ($null -ne $possibleRunBook) {
            #! If we found the runbook, then the directory that it is in is our BuildConfigPath
            Write-Debug "       - Found runbook at : $possibleRunBook"
            $BuildConfigPath = $possibleRunBook | Split-Path -Parent
            $Runbook = $possibleRunBook
            Remove-Variable options, possibleRunBook -ErrorAction SilentlyContinue
            Write-Verbose "Runbook : $Runbook"
        } else {
            Write-Debug "Could not find a runbook"
        }
    } else {
        <#
         ! ProfilePath is set
         If this is the case, and it is a valid path, then we can look for the BuildProfile and find our
         BuildConfigPath if the profile is found
        #>
        Write-Debug "ProfilePath set to $ProfilePath"
        if (Test-Path $ProfilePath) {
            Write-Debug "  - Found $ProfilePath set by -ProfilePath"

            $options = @{
                Path = $ProfilePath
            }

            if (-not ([string]::IsNullorEmpty($BuildProfile))) {
                $options['BuildProfile'] = $BuildProfile
            }

            $possibleRunBook = Select-BuildRunBook @options

            if ($null -ne $possibleRunBook) {
                #! If we found the runbook, then the directory that it is in is our BuildConfigPath
                $BuildConfigPath = $possibleRunBook | Split-Path -Parent
                Remove-Variable options, possibleRunBook -ErrorAction SilentlyContinue

            } else {
                throw "ProfilePath is set, but it does not contain a runbook"
            }
        } else {
            #! In the event that ProfilePath is set to an invalid path, we throw an error instead of
            #! searching BuildConfigRoot
            $errorMessage += "'$ProfilePath' is not a valid path"
        }

    }

    Write-Verbose "Profile path: $ProfilePath"
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
    Write-Debug "Looking for stitch configuration file"
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
                    Write-Debug "Multiple config files found!"
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
