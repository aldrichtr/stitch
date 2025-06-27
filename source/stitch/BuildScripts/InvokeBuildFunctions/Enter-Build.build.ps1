<#
.SYNOPSIS
    Runs at the start of the build
#>


Enter-Build {
    Write-Debug "`n$('-' * 80)`n-- Begin Enter-Build`n$('-' * 80)"

    foreach ($taskToRun in $BuildTask) {
        if ($taskToRun -match '^diag') {
            $Output.Console.Enabled = $false
            $Output.File.Enabled = $false
            $SkipBuildHeader = $true
            $SkipLogo = $true
        }
    }
    $mod = Get-InstalledModule GitHubActions -ErrorAction SilentlyContinue
    if ($null -ne $mod) {
        $GithubOutputEnabled = $true
    } else {
        $GithubOutputEnabled = $false
    }

        Invoke-OutputHook 'EnterBuild' 'Before'


    #-------------------------------------------------------------------------------
    #region Header

    if ((-not($SkipBuildHeader)) -or
        ($WhatIf)) {
        if (-not($SkipLogo)) {
            Write-StitchLogo
        }
        logEnter "$('#' * 80)"
        logEnter "# $stitchEmoji stitch (version $($stitchModule.Version))"
        logEnter "# loaded from $(Resolve-Path $stitchModule.Path -Relative)"
        logEnter "$('#' * 80)"
    }
    #endregion Header
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Handle import errors

    $importErrorCount = $script:ImportErrors.Keys.Count
    if ($importErrorCount -gt 0) {
        $errorLogMessage = @()
        $errorLogMessage += ('-' * 80)
        $errorLogMessage +=  "There were errors during the import of tasks:"

        foreach ($importError in $script:ImportErrors.GetEnumerator()) {
            $errorLogMessage += (@(
                "-- ",
                $importError.Name,
                ": (`n",
                $importError.Value,
                ")"
            ) -join '')
        }
        $errorLogMessage += ('-' * 80)

        logError ($errorLogMessage -join "`n")
    }

    Remove-Variable errorLogMessage, ImportErrors -ErrorAction SilentlyContinue

    #endregion Handle import errors
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Build Configuration Information

    logInfo "Using build profile: $($BuildProfile ?? 'none')"
    logInfo "Configuration directory: $BuildConfigPath"
    logInfo "Gathering Build Configuration data"
    $buildOptions = @{
        Path = $BuildRoot
        ConfigurationFiles = (Join-Path $BuildConfigPath 'config')
        Source = $Source
        Tests = $Tests
        Artifact = $Artifact
        Staging = $Staging
        Docs = $Docs
    }
    try {
        $BuildInfo = Get-BuildConfiguration @buildOptions
    } catch {
        logError "There was an error gathering build configuration data"
        logError $_.ToString()
        logError $_.ScriptStackTrace
        $PSCmdlet.ThrowTerminatingError($_)
    }

    logInfo "Build Configuration loaded.  Found $($BuildInfo.Modules.Count) Modules in Project: $($BuildInfo.Project.Name)"
    #endregion Build Configuration Information
    #-------------------------------------------------------------------------------

    logEnter ('-' * 80)
    logEnter "Beginning execution of tasks.  Tasks to be run:"
    # BuildTask is defined by Invoke-Build.  It is the Tasks defined on the command line
    foreach ($taskToRun in $BuildTask) {
        $taskObject = $taskToRun | Get-BuildTask
        logEnter ('{0,-32} : {1}' -f $taskToRun, $taskObject.Synopsis)
        foreach ($job in $taskObject.Jobs) {
            $jobObject = $job | Get-BuildTask
            if ($job -is [scriptblock]) {
                logEnter ('  - {0,-32} : {1}' -f '{ }', 'scriptblock')
            } else {
                logEnter ('  - {0,-32} : {1}' -f $job, $jobObject.Synopsis)
            }
        }
    }
    logEnter ('-' * 80)
    Invoke-OutputHook 'EnterBuild' 'After'

    Write-Debug "`n$('-' * 80)`n-- End Enter-Build`n$('-' * 80)"
}
