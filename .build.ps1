<#
.SYNOPSIS
    Main build driver for Stitch
#>

param(
    #-------------------------------------------------------------------------------
    #region Stitch task import parameters

    # Do not import tasks from the Stitch module.  This can be used to bypass the
    # import for debug/testing purposes
    [Parameter()]
    [switch]$SkipModuleTaskImport,

    # The information related to the current project including Modules, Paths and
    # Version information.  See Also Get-BuildConfiguration
    [Parameter()][hashtable]$BuildInfo,

    #endregion Stitch task import parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Profile
    # The lifecycle profile to run.  Determines which runbook will be loaded.
    # Runs the `Build` profile if none specified, or the single runbook if only
    # one is found
    [Parameter()][string]$Profile,

    # The regular expression to use to find runbooks
    [Parameter()][string]$ProfilePattern,

    # The directory to search for runbooks
    [Parameter()][string]$ProfilePath,

    #endregion Profile
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Path parameters

    # The path to the source files for this project
    [Parameter()][string]$Source,

    # The path where the Build phase will stage the files it produces.
    [Parameter()][string]$Staging,

    # The path to the Pester tests.
    [Parameter()][string]$Tests,

    # The path to where build files and other artifacts (such as log files, supporting
    # modules, etc.) are written
    [Parameter()][string]$Artifact,

    # The path where documentation (markdown help, etc.) is stored
    [Parameter()][string]$Docs,
    #endregion Path parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Clean phase parameters

    # Paths that should not be deleted when `Clean` is run.  By default everything
    # in`$Staging` and `$Artifact` are removed
    [Parameter()][string[]]$ExcludePathFromClean,
    #endregion Clean phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Validate phase parameters

    # Do not check for module dependencies (PSDepend)
    [Parameter()][switch]$SkipDependencyCheck,

    #endregion Validate phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Test phase parameters

    # Produce codecoverage metrics when running Pester tests
    [Parameter()][switch]$CodeCov,

    [Parameter()]
    [ValidateSet('JaCoCo', 'CoverageGutters')]
    [string]$CodeCovFormat,

    [Parameter()][string]$CodeCovPath,

    [Parameter()][string]$CodeCovFile,

    [Parameter()]
    [ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
    [string]$PesterOutput,

    #endregion Test phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Build phase parameters

    # Additional paths in the `$Source` directory that should be copied to `$Staging`
    [Parameter()][hashtable]$CopyAdditionalItems,

    # Copy the directory even though it contains no items
    [Parameter()][switch]$CopyEmptySourceDirs,

    # `build.manifest.array.format` task will update a manifest so that arrays are
    # written with the '@(' and ')' surrounding the list.
    # Fields listed here will be ignored in the manifest
    [Parameter()][string[]]$SkipManifestArrayFormat,

    # The list of source types to include in the module file (.psm1).
    [Parameter()][string[]]$ModuleFileIncludeTypes,

    # If the value of ModuleFilePrefix is:
    # - null : no changes
    # - A string that resolves to a file (relative to the Module source
    #   directory), the contents of the files will be inserted at the top of
    #   the module file in Staging.
    # - A string that does not resolve to a file, it will be inserted at the top
    #   of the module file in Staging
    [Parameter()][string]$ModuleFilePrefix,

    # If the value of ModuleFileSuffix is:
    # - null : no changes
    # - A string that resolves to a file (relative to the Module source
    #   directory), the contents of the files will be inserted at the bottom of
    #   the module file in Staging.
    # - A string that does not resolve to a file, it will be inserted at the bottom
    #   of the module file in Staging
    [Parameter()][string]$ModuleFileSuffix,

    # Where to make backups of the source manifest prior to updating the version
    # information
    [Parameter()][string]$ManifestBackupPath,

    # Backups are deleted after being restored by default.  Use this flag to restore
    # the changelog from the latest backup and keep the backup file
    [Parameter()][switch]$KeepManifestBackup,

    # The gitversion field to use when setting the current version in the changelog
    [Parameter()][string]$ManifestVersionField,

    # The source directory where PowerShell format files are stored (if any)
    [Parameter()][string]$FormatPsXmlDirectory,

    # The file format used to find Format files in the source
    [Parameter()][string]$FormatPsXmlFileFilter,

    # The source directory where PowerShell type files are stored (if any)
    [Parameter()][string]$TypePsXmlDirectory,

    # The file format used to find Format files in the source
    [Parameter()][string]$TypePsXmlFileFilter,

    #endregion Build phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Deploy phase parameters

    # A table of files, strings to find and replacements for updating version fields
    # in files.
    [Parameter()][hashtable]$ReplaceVersionInFile,

    # The path to the project's changelog (if any)
    [Parameter()][string]$ChangelogPath,

    # Where to make backups of the changlog prior to updating the version
    # information
    [Parameter()][string]$ChangelogBackupPath,

    # Backups are deleted after being restored by default.  Use this flag to restore
    # the changelog from the latest backup and keep the backup file
    [Parameter()][switch]$KeepChangelogBackup,

    # The gitversion field to use when setting the current version in the changelog
    [Parameter()][string]$ChangelogVersionField,

    # Location to save the modules to (copy from staging)
    # See the `install.module.saveto` task
    [Parameter()][string]$InstallSaveToPath,

    # List of modules to save (all modules in project by default)
    # See the `install.module.saveto` task
    [Parameter()][string[]]$InstallSaveToModules,


    # The gitversion field to use when calling `git tag`
    [Parameter()][string]$GitTagVersionField,

    # The name of the temporary PSRepository to create when creating a nuget package
    [Parameter()][string]$ProjectPSRepoName,

    # If publishing the module to a local PSRepository, add the name here
    [Parameter()][string]$PublishToPsRepo,

    #endregion Deploy phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Logging parameters
    # The path to write the build log to.
    # LogPath and LogFile are combined at runtime to determine the path to the build
    # log
    [Parameter()][string]$LogPath,

    # The file name to write the build log to
    [Parameter()][string]$LogFile,

    # A table of output locations (Console and File), Levels (DEBUG, INFO, etc.)
    # and other information that controls the output of the build
    [Parameter()][hashtable]$Output,

    # Suppress Build header and footer output
    [Parameter()][switch]$SkipBuildHeader

    #endregion Logging parameters
    #-------------------------------------------------------------------------------


)
begin {
    $buildConfigPaths = @(
        "$BuildRoot\.build.config.ps1" # preferred
        "$BuildRoot\.build\.config.ps1"
        "$BuildRoot\.build\config.ps1"
    )
    foreach ($file in $buildConfigPaths) {
        if (Test-Path $file) {
            Write-Debug "Config file $(Resolve-Path $file) found"
            . $file
        }
    }
    #-------------------------------------------------------------------------------
    #region Load Stitch module
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    $stitchModule = Get-Module Stitch
    Write-Debug 'Checking if Stitch is already loaded'
    # Only load Stitch if it isn't already loaded.
    if ($null -eq $stitchModule) {
        Write-Debug '  - None found'
        try {
            Import-Module Stitch -NoClobber -ErrorAction Stop
        } catch {
            Write-Error "Could not import Stitch`n$_"
        }
    } else {
        Write-Debug "version $($stitchModule.Version) already loaded"
    }

    Write-Debug "Stitch loaded from $(Get-Module Stitch | Select-Object -ExpandProperty Path)"

    #endregion Load Stitch module
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Define aliases

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

    Set-Alias -Name replace -Value Invoke-ReplaceToken -Description 'Replace tokens in text'
    #endregion Define aliases
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Import Stitch tasks

    if (-not($SkipModuleTaskImport)) {
        $cmd = Get-Command 'Import-StitchTask' -ErrorAction SilentlyContinue
        if ($null -ne $cmd) {
            try {
                . Import-StitchTask
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        } else {
            Write-Error 'Task import not available in this version'
        }
    }
    #endregion Import Stitch tasks
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Import custom tasks
    #! by convention, a `task` file defines a function used to create build task types
    #! while a `build` file contains task definitions
    if (Test-Path '.build') {
        Get-ChildItem -Path '.build' -Filter '*.task.ps1' | ForEach-Object {
            Write-Debug "Importing custom task from $($_.BaseName)"
            . $_.FullName
        }
        Get-ChildItem -Path '.build' -Filter '*.build.ps1' | ForEach-Object {
            Write-Debug "Importing custom task from $($_.BaseName)"
            . $_.FullName
        }
    }

    #endregion Import custom tasks
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region load the profile

    # look for runbooks

    if ([string]::IsNullorEmpty($ProfilePath)) {
        $ProfilePath = '.build'
    }

    if ([string]::IsNullorEmpty($ProfilePattern)) {
        $ProfilePattern = "*runbook.ps1"
    }

    if ([string]::IsNullOrEmpty($Profile)) {
        $Profile = 'build'
    }

    Write-Debug "Looking for runbooks in $ProfilePath using $ProfilePattern"
    $runbooks = (Get-ChildItem $ProfilePath -Filter $ProfilePattern)

    if ($null -ne $runbooks) {
        Write-Debug "  - found $($runbooks.Count) runbooks"
        if ($runbooks.count -eq 1) {
            Write-Debug "    using single runbook"
            $found = $runbooks[0]
        } else {
            $found = $runbooks | Where-Object { $_.Directory.BaseName -like "$Profile"} | Select-Object -First 1
            if ($null -eq $found) {
                $found = $runbooks | Where-Object {$_.BaseName -like "$Profile*"}  | Select-Object -First 1
            }
        }
    } else {
        Write-Debug "  - No runbooks found"
    }

    if ($null -ne $found) {
        $RunBookItem = $found
        Write-Debug "Importing profile $($found.FullName)"
        . $found.FullName
    } else {
        Write-Debug "No runbook matched profile '$Profile'"
    }


    #endregion load the profile
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
