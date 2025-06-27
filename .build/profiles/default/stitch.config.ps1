
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
    The configuration file for the stitch build system
.DESCRIPTION
    This script configures all of the parameters used by the stitch build system.  Any value here can be overriden
    at runtime using the Parameter on the command line.

    By default, each parameter is set using `Get-BuildProperty`.  This function is part of Invoke-Build and will
    look for the variable's value in the current session, the environment variables and then the default.

    See Invoke-Build help for details on the Get-BuildProperty (alias property) command.
#>


#-------------------------------------------------------------------------------
#region Rule suppression

        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ProfilePath', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'BuildProfile', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'DefaultBuildProfile', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'BuildConfigRoot', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'BuildConfigFile', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'Source', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'Staging', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'Tests', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'Artifact', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'Docs', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'SourceTypeMap', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'SkipModuleTaskImport', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'BuildInfo', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ExcludePathFromClean', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'SkipDependencyCheck', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'DependencyTags', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'RequiredModules', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'CodeCov', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'CodeCovFormat', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'CodeCovDirectory', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'CodeCovFile', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'TestResultFormat', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'TestResultDirectory', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'TestResultFile', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'PesterOutput', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'PesterResultDirectory', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'PesterResultFile', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'CopyAdditionalItems', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'CopyEmptySourceDirs', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'SkipManifestArrayFormat', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ModuleFileIncludeTypes', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ModuleFilePrefix', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ModuleFileSuffix', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ModuleNamespace', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ManifestBackupPath', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'KeepManifestBackup', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ManifestVersionField', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'SuppressManifestComments', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ExcludeFunctionsFromExport', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ExcludeAliasFromExport', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'FormatPsXmlDirectory', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'FormatPsXmlFileFilter', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'TypePsXmlDirectory', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'TypePsXmlFileFilter', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'HelpDocsCultureDirectory', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'HelpDocLogFile', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'FormatSettings', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'AnalyzerSettings', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ProjectVersionSource', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ProjectVersionField', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ChangelogPath', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ChangelogBackupPath', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'KeepChangelogBackup', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ChangelogVersionField', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'GitTagVersionField', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'GitStashMessage', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'IncludeUntrackedInGitStash', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ProjectPSRepoName', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'PublishPsRepoName', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'PublishToPsRepo', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'PublishActionIfUncommitted', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'NugetApiKey', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ReleaseNotesFormat', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'ReleaseNotesFile', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'InstallSaveToPath', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'InstallSaveToModules', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'InstallModuleFromPsRepo', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'LogPath', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'LogFile', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'Output', Justification = 'Variable used in Invoke-Build scripts')]
        [SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', 'SkipBuildHeader', Justification = 'Variable used in Invoke-Build scripts')]

#endregion Rule suppression
#-------------------------------------------------------------------------------

param()
#-------------------------------------------------------------------------------
#region Profile

<#
 The base path to configuration and settings files
#>
$BuildConfigRoot = (
    Get-BuildProperty BuildConfigRoot (Join-Path $BuildRoot '.build')
)

<#
 The directory to search for runbooks
#>
$ProfilePath = (
    Get-BuildProperty ProfilePath (Join-Path $BuildConfigRoot 'profiles')
)

<#
 The lifecycle profile to run.  Determines which runbook will be loaded.
 Runs the ``Build`` profile if none specified, or the single runbook if only one is found
#>
$BuildProfile = (
    Get-BuildProperty BuildProfile 'default'
)

<#
 The default BuildProfile if not specified (and more than one runbook exists)
#>
$DefaultBuildProfile = (
    Get-BuildProperty DefaultBuildProfile 'default'
)

#endregion Profile
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Path

<#
 The file name of the configuration file
#>
$BuildConfigFile = (
    Get-BuildProperty BuildConfigFile 'stitch.config.ps1'
)

<#
 The path to the source files for this project
#>
$Source = (
    Get-BuildProperty Source (Join-Path $BuildRoot 'source')
)

<#
 The path where the Build phase will stage the files it produces.
#>
$Staging = (
    Get-BuildProperty Staging (Join-Path $BuildRoot 'stage')
)

<#
 The path to the Pester tests.
#>
$Tests = (
    Get-BuildProperty Tests (Join-Path $BuildRoot 'tests')
)

<#
 The path to where build files and other artifacts (such as log files, supporting modules, etc.) are written
#>
$Artifact = (
    Get-BuildProperty Artifact (Join-Path $BuildRoot 'out')
)

<#
 The path where documentation (markdown help, etc.) is stored
#>
$Docs = (
    Get-BuildProperty Docs (Join-Path $BuildRoot 'docs')
)

<#
 A table that maps source directory names to their types
 for example :
 @{ public = @{Visibility = 'public'; Type = 'function'}}
#>
$SourceTypeMap = (
    Get-BuildProperty SourceTypeMap @{
    # directory name => visibility
    'public'     = @{ Visibility = 'public'; Type = 'function' }
    'class'      = @{ Visibility = 'private'; Type = 'class' }
    'classes'    = @{ Visibility = 'private'; Type = 'class' }
    'enum'       = @{ Visibility = 'private'; Type = 'enum' }
    'private'    = @{ Visibility = 'private'; Type = 'function' }
    'resource'   = @{ Visibility = 'private'; Type = 'resource' }
    'assembly'   = @{ Visibility = 'private'; Type = 'resource' }
    'assemblies' = @{ Visibility = 'private'; Type = 'resource' }
    'data'       = @{ Visibility = 'private'; Type = 'resource' }
}
)

#endregion Path
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Tasks
<#
 Do not import tasks from the Stitch module.  This can be used to bypass the import for debug/testing purposes
#>
$SkipModuleTaskImport = (
    Get-BuildProperty SkipModuleTaskImport $false
)

<#
 The information related to the current project including Modules, Paths and Version information.  See Also Get-BuildConfiguration
#>
$BuildInfo = (
    Get-BuildProperty BuildInfo @{
    Modules = @{}
    Project = @{
        Name = ''
    }
}
)

#endregion Tasks
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Clean
<#
 Paths that should not be deleted when `Clean` is run.  By default everything in`$Staging` and `$Artifact` are removed
#>
$ExcludePathFromClean = (
    Get-BuildProperty ExcludePathFromClean @( "$Artifact\logs*" , "$Artifact\backup*")
)

#endregion Clean
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Validate
<#
 Do not check for module dependencies (PSDepend)
#>
$SkipDependencyCheck = (
    Get-BuildProperty SkipDependencyCheck $false
)

<#
 A list of tags to pass to PSDepend when installing requirements
#>
$DependencyTags = (
    Get-BuildProperty DependencyTags @()
)

<#
 A table of required modules with the Module name as the key and a hashtable with Version and Tag information (see requirements.psd1)
#>
$RequiredModules = (
    Get-BuildProperty RequiredModules @{}
)

#endregion Validate
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Test
<#
 Produce codecoverage metrics when running Pester tests
#>
$CodeCov = (
    Get-BuildProperty CodeCov $false
)

<#
 The format of the Code coverage output (CoverageGutters or JaCoCo)
#>
$CodeCovFormat = (
    Get-BuildProperty CodeCovFormat CoverageGutters
)

<#
 The Path to the directory where the Code Coverage output will be saved
#>
$CodeCovDirectory = (
    Get-BuildProperty CodeCovDirectory (Join-Path $Artifact 'tests')
)

<#
 The name of the Code Coverage output file. Use {Type} and {Format} as replaceable fields
#>
$CodeCovFile = (
    Get-BuildProperty CodeCovFile "pester.{Type}.codecov.{Format}-$(Get-Date -Format FileDateTimeUniversal).xml"
)

<#
 The format of the Test result output (NUnitXml, Nunit2.5, or JUnitXml)
#>
$TestResultFormat = (
    Get-BuildProperty TestResultFormat NUnitXml
)

<#
 The Path to the directory where the Test result output will be saved
#>
$TestResultDirectory = (
    Get-BuildProperty TestResultDirectory (Join-Path $Artifact 'tests')
)

<#
 The name of the Test result output file. Use {Type} and {Format} as replaceable fields
#>
$TestResultFile = (
    Get-BuildProperty TestResultFile "pester.{Type}.testresult.{Format}-$(Get-Date -Format FileDateTimeUniversal).xml"
)

<#
 The output level of Invoke-Pester
#>
$PesterOutput = (
    Get-BuildProperty PesterOutput 'Normal'
)

<#
 The directory to store the Invoke-Pester result object
#>
$PesterResultDirectory = (
    Get-BuildProperty PesterResultDirectory (Join-Path $Artifact 'tests')
)

<#
 The file to store the Invoke-Pester result object
#>
$PesterResultFile = (
    Get-BuildProperty PesterResultFile "pester.{Type}.result.-$(Get-Date -Format FileDateTimeUniversal).clixml"
)

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
$CopyAdditionalItems = (
    Get-BuildProperty CopyAdditionalItems @{}
)

<#
 Copy the directory even though it contains no items
#>
$CopyEmptySourceDirs = (
    Get-BuildProperty CopyEmptySourceDirs $false
)

<#
 build.manifest.array.format task will update a manifest so that arrays are written with '@(' and ')' surrounding the list.  Fields listed here will be ignored in the manifest
#>
$SkipManifestArrayFormat = (
    Get-BuildProperty SkipManifestArrayFormat @()
)

<#
 The list of source types to include in the module file (.psm1).
#>
$ModuleFileIncludeTypes = (
    Get-BuildProperty ModuleFileIncludeTypes @('enum', 'class', 'function')
)

<#
 Either a string or the path to a file whose contents will be inserted at the top of the Module file
 Note that the content of the string is not automatically commented
#>
$ModuleFilePrefix = (
    Get-BuildProperty ModuleFilePrefix ''
)

<#
 Either a string or the path to a file whose contents will be inserted at the bottom of the Module file
#>
$ModuleFileSuffix = (
    Get-BuildProperty ModuleFileSuffix ''
)

<#
 If the module should be part of a larger namespace, set the namespace here.  ModuleNamespace is
 a hashtable where the key is the module name and the value is the namespace like:
 @{
     Module1 = 'Fabricam.Automation'
 }
#>
$ModuleNamespace = (
    Get-BuildProperty ModuleNamespace @{}
)

<#
 Where to make backups of the source manifest prior to updating the version information
#>
$ManifestBackupPath = (
    Get-BuildProperty ManifestBackupPath (Join-Path $Artifact 'backup')
)

<#
 Backups are deleted after being restored by default.  Use this flag to restore the changelog from the latest backup and keep the backup file
#>
$KeepManifestBackup = (
    Get-BuildProperty KeepManifestBackup $false
)

<#
 The gitversion field to use when setting the current version in the changelog
#>
$ManifestVersionField = (
    Get-BuildProperty ManifestVersionField 'MajorMinorPatch'
)

<#
 Do not use New-ModuleManifest with parameters from the source, just copy directly
#>
$SuppressManifestComments = (
    Get-BuildProperty SuppressManifestComments $false
)

<#
 Functions listed in this array will not be added to the FunctionsToExport array at build time
#>
$ExcludeFunctionsFromExport = (
    Get-BuildProperty ExcludeFunctionsFromExport @()
)

<#
 Aliases listed in this array will not be added to the AliasesToExport array at build time
#>
$ExcludeAliasFromExport = (
    Get-BuildProperty ExcludeAliasFromExport @()
)

<#
 The source directory where PowerShell format files are stored (if any)
#>
$FormatPsXmlDirectory = (
    Get-BuildProperty FormatPsXmlDirectory 'Formats'
)

<#
 The file format used to find Format files in the source
#>
$FormatPsXmlFileFilter = (
    Get-BuildProperty FormatPsXmlFileFilter '*.Format.ps1xml'
)

<#
 The source directory where PowerShell type files are stored (if any)
#>
$TypePsXmlDirectory = (
    Get-BuildProperty TypePsXmlDirectory 'Types'
)

<#
 The file format used to find Format files in the sourcetypes
#>
$TypePsXmlFileFilter = (
    Get-BuildProperty TypePsXmlFileFilter '*.Type.ps1xml'
)

<#
 Set the name of the directory to export external help MAML file to
#>
$HelpDocsCultureDirectory = (
    Get-BuildProperty HelpDocsCultureDirectory (Get-Culture | Select-Object -Expand Name)
)

<#
 The path to a log file for the PlatyPS Update-MarkdownHelp command
#>
$HelpDocLogFile = (
    Get-BuildProperty HelpDocLogFile (Join-Path $Artifact "platyps_$(Get-Date -Format 'yyyy.MM.dd.HH.mm').log")
)

<#
 Settings for the Invoke-Formatter function
 Either a path to a psd1 file or a hashtable of settings
#>
$FormatSettings = (
    Get-BuildProperty FormatSettings (Join-Path $BuildRoot "CodeFormatting.psd1")
)

<#
 Settings for the Invoke-ScriptAnalyzer function
 Either a path to a psd1 file or a hashtable of settings
#>
$AnalyzerSettings = (
    Get-BuildProperty AnalyzerSettings (Join-Path $BuildRoot "PSScriptAnalyzerSetting.psd1")
)

<#
 How to retrieve the version information.  Can be one of 'gitversion', 'gitdescribe' or 'file'
#>
$ProjectVersionSource = (
    Get-BuildProperty ProjectVersionSource gitversion
)

<#
 The field in the version info to use for the module version
#>
$ProjectVersionField = (
    Get-BuildProperty ProjectVersionField MajorMinorPatch
)

#endregion Build
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Publish
<#
 The path to the project's changelog (if any)
#>
$ChangelogPath = (
    Get-BuildProperty ChangelogPath (Join-Path $BuildRoot 'CHANGELOG.md')
)

<#
 Where to make backups of the changlog prior to updating the version information
#>
$ChangelogBackupPath = (
    Get-BuildProperty ChangelogBackupPath (Join-Path $Artifact 'backup')
)

<#
 Backups are deleted after being restored by default.  Use this flag to restore the changelog from the latest backup and keep the backup file
#>
$KeepChangelogBackup = (
    Get-BuildProperty KeepChangelogBackup $false
)

<#
 The gitversion field to use when setting the current version in the changelog
#>
$ChangelogVersionField = (
    Get-BuildProperty ChangelogVersionField 'MajorMinorPatch'
)

<#
 The gitversion field to use when calling `git tag`
#>
$GitTagVersionField = (
    Get-BuildProperty GitTagVersionField 'MajorMinorPatch'
)

<#
 An optional message to use when creating a git stash
#>
$GitStashMessage = (
    Get-BuildProperty GitStashMessage ''
)

<#
 When creating a git stash, also stash untracked files
#>
$IncludeUntrackedInGitStash = (
    Get-BuildProperty IncludeUntrackedInGitStash $false
)

<#
 The name of the temporary PSRepository to create when creating a nuget package
#>
$ProjectPSRepoName = (
    Get-BuildProperty ProjectPSRepoName $BuildInfo.Project.Name
)

<#
 The name of the PSRepository to publish the module to
#>
$PublishPsRepoName = (
    Get-BuildProperty PublishPsRepoName 'PSGallery'
)

<#
 If publishing the module to a local PSRepository, add the name here
#>
$PublishToPsRepo = (
    Get-BuildProperty PublishToPsRepo 'local'
)

<#
 What to do if publishing the module and there are uncommited changes
 - stash : perform a git stash before continuing
 - ignore : procede with publish task
 - abort : fail the build
#>
$PublishActionIfUncommitted = (
    Get-BuildProperty PublishActionIfUncommitted 'local'
)

<#
 The API key to use when publishing to PublishPsRepoName
#>
$NugetApiKey = (
    Get-BuildProperty NugetApiKey (Get-Secret NugetApiKey -AsPlainText)
)

<#
 The format used for adding release notes to the manifest, can be one of 'text' or 'url'
#>
$ReleaseNotesFormat = (
    Get-BuildProperty ReleaseNotesFormat text
)

<#
 The path to the releasenotes file to use
#>
$ReleaseNotesFile = (
    Get-BuildProperty ReleaseNotesFile ReleaseNotes.md
)

#endregion Publish
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Install
<#
 Location to save the modules to (copy from staging) See the `install.module.saveto` task
#>
$InstallSaveToPath = (
    Get-BuildProperty InstallSaveToPath (Resolve-Path ($env:PSModulePath -split ';' | Select-Object -First 1))
)

<#
 List of modules to save (all modules in project by default) See the `install.module.saveto` task
#>
$InstallSaveToModules = (
    Get-BuildProperty InstallSaveToModules $BuildInfo.Modules.Keys
)

<#
 When installing the project's modules, use this repository as the source
#>
$InstallModuleFromPsRepo = (
    Get-BuildProperty InstallModuleFromPsRepo $BuildInfo.Project.Name
)

#endregion Install
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Logging
<#
 The path to write the build log to. LogPath and LogFile are combined at runtime to determine the path to the build log
#>
$LogPath = (
    Get-BuildProperty LogPath (Join-Path $Artifact 'logs')
)

<#
 The file name to write the build log to
#>
$LogFile = (
    Get-BuildProperty LogFile "build-$(Get-Date -Format FileDateTimeUniversal).log"
)

<#
 A table of output locations (Console and File), Levels (DEBUG, INFO, etc.) and other information that controls the output of the build
#>
$Output = (
    Get-BuildProperty Output  @{
        Timestamp         = @{
            Format          = '%s'
            ForegroundColor = 'BrightWhite'
        }
        Console           = @{
            Enabled = $true
            Level   = 'DEBUG'
            Message = @{
                ForegroundColor = 'White'
            }
        }
        File              = @{
            Enabled = $false
            Level   = 'DEBUG'
        }
        5                 = @{
            ForegroundColor = 'BrightBlack'
            Label           = 'DEBUG'
        }
        4                 = @{
            ForegroundColor = 'Blue'
            Label           = 'INFO'
        }
        3                 = @{
            ForegroundColor = 'Yellow'
            Label           = 'WARN'
        }
        2                 = @{
            ForegroundColor = 'Red'
            Label           = 'ERROR'
        }
        'clean.artifacts' = 'INFO'
        'clean.staging'   = 'INFO'
    }
)

<#
 Suppress Build header and footer output
#>
$SkipBuildHeader = (
    Get-BuildProperty SkipBuildHeader $false
)

#endregion Logging
#-------------------------------------------------------------------------------
