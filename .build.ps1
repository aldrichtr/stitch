
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
    Main build script for the stitch build system
.DESCRIPTION
    This script is intended to be used by Invoke-Build.  It loads all of the required functions, tasks and helpers
    and then runs the requested tasks

    To see a list of tasks available, run `Invoke-Build ?`
#>

#-------------------------------------------------------------------------------
#region Rule suppression

[SuppressMessage('PSReviewUnusedParameter', 'ProfilePath',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'BuildProfile',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'DefaultBuildProfile',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'BuildConfigRoot',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'BuildConfigFile',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'Source',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'Staging',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'Tests',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'Artifact',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'Docs',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'SourceTypeMap',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'SkipModuleTaskImport',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'BuildInfo',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ExcludePathFromClean',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'SkipDependencyCheck',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'DependencyTags',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'CodeCov',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'CodeCovFormat',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'CodeCovDirectory',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'CodeCovFile',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'TestResultFormat',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'TestResultDirectory',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'TestResultFile',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'PesterOutput',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'PesterResultDirectory',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'PesterResultFile',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'CopyAdditionalItems',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'CopyEmptySourceDirs',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'SkipManifestArrayFormat',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ModuleFileIncludeTypes',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ModuleFilePrefix',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ModuleFileSuffix',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ModuleNamespace',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ManifestBackupPath',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'KeepManifestBackup',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ManifestVersionField',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'SuppressManifestComments',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ExcludeFunctionsFromExport',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ExcludeAliasFromExport',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'FormatPsXmlDirectory',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'FormatPsXmlFileFilter',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'TypePsXmlDirectory',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'TypePsXmlFileFilter',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'HelpDocsCultureDirectory',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'HelpDocLogFile',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ChangelogPath',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ChangelogBackupPath',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'KeepChangelogBackup',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ChangelogVersionField',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'GitTagVersionField',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'GitStashMessage',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'IncludeUntrackedInGitStash',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'ProjectPSRepoName',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'PublishPsRepoName',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'PublishToPsRepo',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'PublishActionIfUncommitted',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'NugetApiKey',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'InstallSaveToPath',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'InstallSaveToModules',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'InstallModuleFromPsRepo',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'LogPath',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'LogFile',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'Output',
    Justification = 'Parameters used in separate task files' )]
[SuppressMessage('PSReviewUnusedParameter', 'SkipBuildHeader',
    Justification = 'Parameters used in separate task files' )]

#endregion Rule suppression
#-------------------------------------------------------------------------------

param(
    #-------------------------------------------------------------------------------
    #region Profile

    <#
    The directory to search for runbooks
    #>
    [Parameter()][String]$ProfilePath,

    <#
    The lifecycle profile to run.  Determines which runbook will be loaded.
    Runs the ``Build`` profile if none specified, or the single runbook if only one is found
    #>
    [Parameter()]
    [Alias('Profile')][String]$BuildProfile,

    <#
    The default BuildProfile if not specified (and more than one runbook exists)
    #>
    [Parameter()][String]$DefaultBuildProfile,

    #endregion Profile
    #-------------------------------------------------------------------------------
    #-------------------------------------------------------------------------------
    #region Path

    <#
    The base path to configuration and settings files
    #>
    [Parameter()][String]$BuildConfigRoot,

    <#
    The file name of the configuration file
    #>
    [Parameter()][String]$BuildConfigFile,

    <#
    The path to the source files for this project
    #>
    [Parameter()][String]$Source,

    <#
    The path where the Build phase will stage the files it produces.
    #>
    [Parameter()][String]$Staging,

    <#
    The path to the Pester tests.
    #>
    [Parameter()][String]$Tests,

    <#
    The path to where build files and other artifacts (such as log files, supporting modules, etc.) are written
    #>
    [Parameter()][String]$Artifact,

    <#
    The path where documentation (markdown help, etc.) is stored
    #>
    [Parameter()][String]$Docs,

    <#
    A table that maps source directory names to their types
    for example :
    @{ public = @{Visibility = 'public'; Type = 'function'}}
    #>
    [Parameter()][hashtable]$SourceTypeMap,

    #endregion Path
    #-------------------------------------------------------------------------------
    #-------------------------------------------------------------------------------
    #region Tasks

    <#
    Do not import tasks from the Stitch module.  This can be used to bypass the import for debug/testing purposes
    #>
    [Parameter()][switch]$SkipModuleTaskImport,

    <#
    The information related to the current project including Modules, Paths and Version information.  See Also Get-BuildConfiguration
    #>
    [Parameter()][Hashtable]$BuildInfo,

    #endregion Tasks
    #-------------------------------------------------------------------------------
    #-------------------------------------------------------------------------------
    #region Clean

    <#
    Paths that should not be deleted when `Clean` is run.  By default everything in`$Staging` and `$Artifact` are removed
    #>
    [Parameter()][String[]]$ExcludePathFromClean,

    #endregion Clean
    #-------------------------------------------------------------------------------
    #-------------------------------------------------------------------------------
    #region Validate

    <#
    Do not check for module dependencies (PSDepend)
    #>
    [Parameter()][switch]$SkipDependencyCheck,

    <#
    A list of tags to pass to PSDepend when installing requirements
    #>
    [Parameter()][string[]]$DependencyTags,

    #endregion Validate
    #-------------------------------------------------------------------------------
    #-------------------------------------------------------------------------------
    #region Test

    <#
    Produce codecoverage metrics when running Pester tests
    #>
    [Parameter()][switch]$CodeCov,

    <#
    The format of the Code coverage output (CoverageGutters or JaCoCo)
    #>
    [Parameter()][String]$CodeCovFormat,

    <#
    The Path to the directory where the Code Coverage output will be saved
    #>
    [Parameter()][String]$CodeCovDirectory,

    <#
    The name of the Code Coverage output file. Use {Type} and {Format} as replaceable fields
    #>
    [Parameter()][String]$CodeCovFile,

    <#
    The format of the Test result output (NUnitXml, Nunit2.5, or JUnitXml)
    #>
    [Parameter()][String]$TestResultFormat,

    <#
    The Path to the directory where the Test result output will be saved
    #>
    [Parameter()][String]$TestResultDirectory,

    <#
    The name of the Test result output file. Use {Type} and {Format} as replaceable fields
    #>
    [Parameter()][String]$TestResultFile,

    <#
    The output level of Invoke-Pester
    #>
    [Parameter()][String]$PesterOutput,

    <#
    The directory to store the Invoke-Pester result object
    #>
    [Parameter()][String]$PesterResultDirectory,

    <#
    The file to store the Invoke-Pester result object
    #>
    [Parameter()][String]$PesterResultFile,

    #endregion Test
    #-------------------------------------------------------------------------------
    #-------------------------------------------------------------------------------
    #region Build

    <#
    Additional paths in the `$Source` directory that should be copied to `$Staging`
    Each key of this hashtable is a module name of your project whose value is a hashtable of Source = Staging paths
    Specify paths relative to your module's source directory on the left and one of three options on the right:
    - a path relative to your module's staging directory
    - $true to use the same relative path
    - $false to skip
    Like
    @{
        Module1 = @{
            data/configuration.data.psd1 = resources/config.psd1
        }
    }
    This will copy <source>/Module1/data/configuration.data.psd1 to <staging>/Module1/resources/config.psd1
    #>
    [Parameter()][Hashtable]$CopyAdditionalItems,

    <#
    Copy the directory even though it contains no items
    #>
    [Parameter()][switch]$CopyEmptySourceDirs,

    <#
    build.manifest.array.format task will update a manifest so that arrays are written with '@(' and ')' surrounding the list.  Fields listed here will be ignored in the manifest
    #>
    [Parameter()][String[]]$SkipManifestArrayFormat,

    <#
    The list of source types to include in the module file (.psm1).
    #>
    [Parameter()][String[]]$ModuleFileIncludeTypes,

    <#
    Either a string or the path to a file whose contents will be inserted at the top of the Module file
    Note that the content of the string is not automatically commented
    #>
    [Parameter()][String]$ModuleFilePrefix,

    <#
    Either a string or the path to a file whose contents will be inserted at the bottom of the Module file
    #>
    [Parameter()][String]$ModuleFileSuffix,

    <#
    If the module should be part of a larger namespace, set the namespace here.  ModuleNamespace is
    a hashtable where the key is the module name and the value is the namespace like:
    @{
        Module1 = 'Fabricam.Automation'
    }
    #>
    [Parameter()][hashtable]$ModuleNamespace,

    <#
    Where to make backups of the source manifest prior to updating the version information
    #>
    [Parameter()][String]$ManifestBackupPath,

    <#
    Backups are deleted after being restored by default.  Use this flag to restore the changelog from the latest backup and keep the backup file
    #>
    [Parameter()][switch]$KeepManifestBackup,

    <#
    The gitversion field to use when setting the current version in the changelog
    #>
    [Parameter()][String]$ManifestVersionField,

    <#
    Do not use New-ModuleManifest with parameters from the source, just copy directly
    #>
    [Parameter()][switch]$SuppressManifestComments,

    <#
    Functions listed in this array will not be added to the FunctionsToExport array at build time
    #>
    [Parameter()][string[]]$ExcludeFunctionsFromExport,

    <#
    Aliases listed in this array will not be added to the AliasesToExport array at build time
    #>
    [Parameter()][string[]]$ExcludeAliasFromExport,

    <#
    The source directory where PowerShell format files are stored (if any)
    #>
    [Parameter()][String]$FormatPsXmlDirectory,

    <#
    The file format used to find Format files in the source
    #>
    [Parameter()][String]$FormatPsXmlFileFilter,

    <#
    The source directory where PowerShell type files are stored (if any)
    #>
    [Parameter()][String]$TypePsXmlDirectory,

    <#
    The file format used to find Format files in the sourcetypes
    #>
    [Parameter()][String]$TypePsXmlFileFilter,

    <#
    Set the name of the directory to export external help MAML file to
    #>
    [Parameter()][String]$HelpDocsCultureDirectory,

    <#
    The path to a log file for the PlatyPS Update-MarkdownHelp command
    #>
    [Parameter()][string]$HelpDocLogFile,

    #endregion Build
    #-------------------------------------------------------------------------------
    #-------------------------------------------------------------------------------
    #region Publish

    <#
    The path to the project's changelog (if any)
    #>
    [Parameter()][String]$ChangelogPath,

    <#
    Where to make backups of the changlog prior to updating the version information
    #>
    [Parameter()][String]$ChangelogBackupPath,

    <#
    Backups are deleted after being restored by default.  Use this flag to restore the changelog from the latest backup and keep the backup file
    #>
    [Parameter()][switch]$KeepChangelogBackup,

    <#
    The gitversion field to use when setting the current version in the changelog
    #>
    [Parameter()][String]$ChangelogVersionField,

    <#
    The gitversion field to use when calling `git tag`
    #>
    [Parameter()][String]$GitTagVersionField,

    <#
    An optional message to use when creating a git stash
    #>
    [Parameter()][String]$GitStashMessage,

    <#
    When creating a git stash, also stash untracked files
    #>
    [Parameter()][switch]$IncludeUntrackedInGitStash,

    <#
    The name of the temporary PSRepository to create when creating a nuget package
    #>
    [Parameter()][String]$ProjectPSRepoName,

    <#
    The name of the PSRepository to publish the module to
    #>
    [Parameter()][String]$PublishPsRepoName,

    <#
    If publishing the module to a local PSRepository, add the name here
    #>
    [Parameter()][String]$PublishToPsRepo,

    <#
    What to do if publishing the module and there are uncommited changes
    - stash : perform a git stash before continuing
    - ignore : procede with publish task
    - abort : fail the build
    #>
    [Parameter()][String]$PublishActionIfUncommitted,

    <#
    The API key to use when publishing to PublishPsRepoName
    #>
    [Parameter()][string]$NugetApiKey,

    #endregion Publish
    #-------------------------------------------------------------------------------
    #-------------------------------------------------------------------------------
    #region Install

    <#
    Location to save the modules to (copy from staging) See the `install.module.saveto` task
    #>
    [Parameter()][String]$InstallSaveToPath,

    <#
    List of modules to save (all modules in project by default) See the `install.module.saveto` task
    #>
    [Parameter()][String[]]$InstallSaveToModules,

    <#
    When installing the project's modules, use this repository as the source
    #>
    [Parameter()][string]$InstallModuleFromPsRepo,

    #endregion Install
    #-------------------------------------------------------------------------------
    #-------------------------------------------------------------------------------
    #region Logging

    <#
    The path to write the build log to. LogPath and LogFile are combined at runtime to determine the path to the build log
    #>
    [Parameter()][String]$LogPath
    ,


    <#
    The file name to write the build log to
    #>
    [Parameter()][String]$LogFile
    ,


    <#
    A table of output locations (Console and File), Levels (DEBUG, INFO, etc.) and other information that controls the output of the build
    #>
    [Parameter()][Hashtable]$Output
    ,


    <#
    Suppress Build header and footer output
    #>
    [Parameter()][switch]$SkipBuildHeader



    #endregion Logging
    #-------------------------------------------------------------------------------
)


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
