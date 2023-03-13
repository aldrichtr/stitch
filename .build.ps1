<#
.SYNOPSIS
    Main build driver for the Stitch project management system.

.DESCRIPTION
    This is the main entry point for using stitch with Invoke-Build.

.LINK
  Get-BuildConfiguration
  Initialize-StitchBuildSystem
  Invoke-Build

#>


param(
    #-------------------------------------------------------------------------------
    #region Profile

    <#
     The lifecycle profile to run.  Determines which runbook will be loaded.
     Runs the `Build` profile if none specified, or the single runbook if only
     one is found
    #>
    [Parameter()]
    [Alias('Profile')]
    [string]$BuildProfile,

    <#
     The regular expression to use to find runbooks
    #>
    [Parameter()][string]$ProfilePattern,

    <#
     The directory to search for runbooks
    #>
    [Parameter()][string]$ProfilePath,

    <#
     The default BuildProfile if not specified (and more than one runbook exists)
    #>
    [Parameter()][string]$DefaultBuildProfile,

    #endregion Profile
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Path parameters

    <#
     The base path to configuration and settings files
    #>
    [Parameter()][string]$BuildConfigRoot,

    <#
     The path to configuration and settings files for "this" profile
    #>
    [Parameter()][string]$BuildConfigPath,

    <#
     The file name of the configuration file
    #>
    [Parameter()][string]$BuildConfigFile,

    <#
     The path to the source files for this project
    #>
    [Parameter()][string]$Source,

    <#
     The path where the Build phase will stage the files it produces.
    #>
    [Parameter()][string]$Staging,

    <#
     The path to the Pester tests.
    #>
    [Parameter()][string]$Tests,

    <#
     The path to where build files and other artifacts (such as log files, supporting
     modules, etc.) are written
    #>
    [Parameter()][string]$Artifact,

    <#
    The path where documentation (markdown help, etc.) is stored
    #>
    [Parameter()][string]$Docs,

    #endregion Path parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Stitch task import parameters

    <#
     Do not import tasks from the Stitch module.  This can be used to bypass the
     import for debug/testing purposes
    #>
    [Parameter()]
    [switch]$SkipModuleTaskImport,

    <#
     The information related to the current project including Modules, Paths and
     Version information.  See Also Get-BuildConfiguration
    #>
    [Parameter()][hashtable]$BuildInfo,

    #endregion Stitch task import parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Phase configuration parameters

    <#
     The path to look for custom phase definitions
    #>
    [Parameter()]
    [string]$CustomPhasePath,

    <#
     The file filter to use to find the phase definition files
    #>
    [Parameter()]
    [string]$CustomPhaseFilter,

    #endregion Phase configuration parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Clean phase parameters

    <#
     Paths that should not be deleted when `Clean` is run.  By default everything
     in`$Staging` and `$Artifact` are removed
    #>
    [Parameter()][string[]]$ExcludePathFromClean,
    #endregion Clean phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Validate phase parameters

    <#
     Do not check for module dependencies (PSDepend)
    #>
    [Parameter()][switch]$SkipDependencyCheck,

    #endregion Validate phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Test phase parameters

    <#
     Produce codecoverage metrics when running Pester tests
    #>
    [Parameter()][switch]$CodeCov,

    [Parameter()]
    [ValidateSet('JaCoCo', 'CoverageGutters')]
    [string]$CodeCovFormat,

    <#
     The Path to the directory where the Code Coverage output will be saved
    #>
    [Parameter()][string]$CodeCovPath,

    <#
     The name of the Code Coverage output file
    #>
    [Parameter()][string]$CodeCovFile,

    <#
     The output level of Invoke-Pester
    #>
    [Parameter()]
    [ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
    [string]$PesterOutput,

    #endregion Test phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Build phase parameters

    <#
     Additional paths in the `$Source` directory that should be copied to `$Staging`
    #>
    [Parameter()][hashtable]$CopyAdditionalItems,

    <#
     Copy the directory even though it contains no items
    #>
    [Parameter()][switch]$CopyEmptySourceDirs,

    <#
    `build.manifest.array.format` task will update a manifest so that arrays are written with the '@(' and ')'
     surrounding the list.  Fields listed here will be ignored in the manifest
    #>
    [Parameter()][string[]]$SkipManifestArrayFormat,

    <#
     The list of source types to include in the module file (.psm1).
    #>
    [Parameter()][string[]]$ModuleFileIncludeTypes,

    <#
     If the value of ModuleFilePrefix is:
       - null : no changes
       - A string that resolves to a file (relative to the Module source
         directory), the contents of the files will be inserted at the top of
         the module file in Staging.
       - A string that does not resolve to a file, it will be inserted at the top
         of the module file in Staging
    #>
    [Parameter()][string]$ModuleFilePrefix,

    <#
    If the value of ModuleFileSuffix is:
       - null : no changes
       - A string that resolves to a file (relative to the Module source
         directory), the contents of the files will be inserted at the bottom of
         the module file in Staging.
       - A string that does not resolve to a file, it will be inserted at the bottom
         of the module file in Staging
    #>
    [Parameter()][string]$ModuleFileSuffix,

    <#
     Where to make backups of the source manifest prior to updating the version
     information
    #>
    [Parameter()][string]$ManifestBackupPath,

    <#
     Backups are deleted after being restored by default.  Use this flag to restore
     the changelog from the latest backup and keep the backup file
    #>
    [Parameter()][switch]$KeepManifestBackup,

    <#
     The gitversion field to use when setting the current version in the changelog
    #>
    [Parameter()][string]$ManifestVersionField,

    <#
     The source directory where PowerShell format files are stored (if any)
    #>
    [Parameter()][string]$FormatPsXmlDirectory,

    <#
     The file format used to find Format files in the source
    #>
    [Parameter()][string]$FormatPsXmlFileFilter,

    <#
     The source directory where PowerShell type files are stored (if any)
    #>
    [Parameter()][string]$TypePsXmlDirectory,

    <#
     The file format used to find Format files in the sourcetypes
    #>
    [Parameter()][string]$TypePsXmlFileFilter,

    #endregion Build phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Deploy phase parameters

    <#
     A table of files, strings to find and replacements for updating version fields
     in files.
    #>
    [Parameter()][hashtable]$ReplaceVersionInFile,

    <#
     The path to the project's changelog (if any)
    #>
    [Parameter()][string]$ChangelogPath,

    <#
     Where to make backups of the changlog prior to updating the version
     information
    #>
    [Parameter()][string]$ChangelogBackupPath,

    <#
     Backups are deleted after being restored by default.  Use this flag to restore
     the changelog from the latest backup and keep the backup file
    #>
    [Parameter()][switch]$KeepChangelogBackup,

    <#
     The gitversion field to use when setting the current version in the changelog
    #>
    [Parameter()][string]$ChangelogVersionField,

    <#
     Location to save the modules to (copy from staging)
     See the `install.module.saveto` task
    #>
    [Parameter()][string]$InstallSaveToPath,

    <#
     List of modules to save (all modules in project by default)
     See the `install.module.saveto` task
    #>
    [Parameter()][string[]]$InstallSaveToModules,


    <#
     The gitversion field to use when calling `git tag`
    #>
    [Parameter()][string]$GitTagVersionField,

    <#
     The name of the temporary PSRepository to create when creating a nuget package
    #>
    [Parameter()][string]$ProjectPSRepoName,

    <#
     If publishing the module to a local PSRepository, add the name here
    #>
    [Parameter()][string]$PublishToPsRepo,

    #endregion Deploy phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Logging parameters

    <#
     The path to write the build log to.
     LogPath and LogFile are combined at runtime to determine the path to the build
     log
    #>
    [Parameter()][string]$LogPath,

    <#
     The file name to write the build log to
    #>
    [Parameter()][string]$LogFile,

    <#
     A table of output locations (Console and File), Levels (DEBUG, INFO, etc.)
     and other information that controls the output of the build
    #>
    [Parameter()][hashtable]$Output,

    <#
     Suppress Build header and footer output
    #>
    [Parameter()][switch]$SkipBuildHeader


    #endregion Logging parameters
    #-------------------------------------------------------------------------------

)

begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
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
    Write-Debug 'Setting aliases for use in tasks'
    Set-Alias -Name call -Value *Task -Description 'Call an Invoke-Build task from within another task'

    Set-Alias -Name phase -Value Add-BuildTask -Description 'Top level task associated with a development lifecycle phase'

    Set-Alias -Name replace -Value Invoke-ReplaceToken -Description 'Replace tokens in text'
    Write-Debug '  - Complete'
    #endregion Define aliases
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Load Stitch module
    Write-Debug 'Loading the stitch module'
    $stitchModule = Get-Module Stitch
    Write-Debug '  - Checking if Stitch is already loaded'
    # Only load Stitch if it isn't already loaded.
    if ($null -eq $stitchModule) {
        Write-Debug '    - None found'
        try {
            Import-Module Stitch -NoClobber -ErrorAction Stop
        } catch {
            Write-Error "Could not import Stitch`n$_"
        }
    } else {
        Write-Debug "  - Version $($stitchModule.Version) already loaded"
    }

    Write-Debug "   - Stitch loaded from $(Get-Module Stitch | Select-Object -ExpandProperty Path)"

    #endregion Load Stitch module
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region load the profile
    Write-Debug 'Loading the configuration'
    if ([string]::IsNullorEmpty($BuildConfigRoot)) {
        $BuildConfigRoot = (Join-Path $BuildRoot '.build')
    }
    Write-Debug "  - Starting in $BuildConfigRoot"
    # look for runbooks

    Write-Debug 'Loading build profile'
    #! In the simplest layout, one folder (BuildConfigRoot) contains all the files
    if ([string]::IsNullorEmpty($ProfilePath)) {
        $ProfilePath = $BuildConfigRoot
    }

    if ([string]::IsNullorEmpty($ProfilePattern)) {
        $ProfilePattern = '*runbook.ps1'
    }

    # now that we have set up our search criteria, look for runbooks
    Write-Debug "  - Looking for runbooks in $ProfilePath using $ProfilePattern"

    $runbooks = (Get-ChildItem $ProfilePath -Filter $ProfilePattern -Recurse)

    if ($null -ne $runbooks) {
        # we found at least one
        Write-Debug "    - found $($runbooks.Count) runbooks"
        if ($runbooks.count -eq 1) {
            Write-Debug '      - Found single runbook'
            $found = $runbooks[0]
        } else {
            if (-not([string]::IsNullorEmpty($BuildProfile))) {
                Write-Error 'Multiple runbooks found, but no BuildProfile set'
            } else {
                $found = $runbooks | Where-Object { $_.Directory.BaseName -like "$Profile" } | Select-Object -First 1
                Write-Debug '      - using single runbook'
                if ($null -eq $found) {
                    $found = $runbooks | Where-Object { $_.BaseName -like "$Profile*" }  | Select-Object -First 1
                }
            }
        }
    } else {
        Write-Debug '  - No runbooks found'
    }

    if ($null -ne $found) {
        $relative = [IO.Path]::GetRelativePath($ProfilePath, $found.FullName)
        $parts = $relative -split [regex]::Escape([IO.Path]::DirectorySeparatorChar)

        Write-Debug "  - runbook is $($parts.Count) levels: $($parts -join ', ')"
        if ($parts.Count -gt 1) {
            $BuildConfigPath = $found.DirectoryName
            if ([string]::IsNullorEmpty($BuildProfile)) {
                $BuildProfile = $found.Directory.BaseName
            }
            Write-Debug "  - Setting BuildConfigPath to $BuildConfigPath"
            Write-Debug "  - Setting BuildProfile to $BuildProfile"
        }
        Write-Debug "  - Setting Runbook to $($found.FullName)"
        $Runbook = $found.FullName

    } else {
        Write-Debug "  - No runbook matched profile '$Profile'"
    }
    Remove-Variable runbooks, found, parts, relative

    #endregion load the profile
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Import custom tasks
    Write-Debug 'Loading build configuration'
    if ([string]::IsNullorEmpty($BuildConfigFile)) {
        $BuildConfigFile = '.config.ps1'
    }

    foreach ($configPath in @( $BuildConfigPath, $BuildConfigRoot)) {
        $file = (Join-Path $configPath $BuildConfigFile)
        if (Test-Path $file) {
            Write-Debug "  - importing config file $(Resolve-Path $file)"
            . $file
        }
        #! by convention, a `task` file defines a function used to create build task types
        #! while a `build` file contains task definitions
        if (Test-Path $configPath) {
            Get-ChildItem -Path $configPath -Filter '*.task.ps1' -Recurse | ForEach-Object {
                Write-Debug "  - importing custom task from $($_.BaseName)"
                . $_.FullName
            }
            Get-ChildItem -Path $configPath -Filter '*.build.ps1' -Recurse | ForEach-Object {
                Write-Debug "  - importing custom task from $($_.BaseName)"
                . $_.FullName
            }
        }
    }

    Remove-Variable configPath, file
    Write-Debug '  - Complete'
    #endregion Import custom tasks
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Import Stitch tasks

    Write-Debug 'Loading build scripts from stitch module '
    if (-not($SkipModuleTaskImport)) {
        $cmd = Get-Command 'Import-StitchTask' -ErrorAction SilentlyContinue
        if ($null -ne $cmd) {
            try {
                Write-Debug '  - Calling Import function'
                . Import-StitchTask
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        } else {
            Write-Error 'Task import not available in this version'
        }
    }
    Write-Debug '  - Complete'
    #endregion Import Stitch tasks
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Load the runbook
    if (Test-Path $Runbook) {
        Write-Debug "Importing runbook $Runbook"
        . $Runbook
    }
    Write-Debug '  - Complete'
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
