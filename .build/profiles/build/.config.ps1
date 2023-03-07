

#-------------------------------------------------------------------------------
#region BuildTool task import parameters
$SkipModuleTaskImport = (
    Get-BuildProperty SkipModuleTaskImport $false
)

$BuildConfigRoot = (Join-Path $BuildRoot '.build')

# The path to configuration and settings files for "this" Profile
$BuildConfigPath = $BuildConfigRoot

# The file name of the configuration file
$BuildConfigFile = '.config.ps1'



$BuildInfo = (
    Get-BuildProperty BuildInfo @{
        Modules = @{}
        Project = @{
            Name = 'stitch'
        }
    }
)
#endregion BuildTool task import parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Profile
# The lifecycle profile to run.  Determines which runbook will be loaded.
# Runs the `Build` profile if none specified, or the single runbook if only
# one is found
$BuildProfile = 'build'

# The regular expression to use to find runbooks
$ProfilePattern = '*runbook.ps1'

# The directory to search for runbooks
$ProfilePath = '.build'

#endregion Profile
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Path parameters

$Source = (
    Get-BuildProperty Source "$BuildRoot\source"
)


$Staging = (
    Get-BuildProperty Staging "$BuildRoot\stage"
)


$Tests = (
    Get-BuildProperty Tests "$BuildRoot\tests"
)


$Artifact = (
    Get-BuildProperty Artifact "$BuildRoot\out"
)


$Docs = (
    Get-BuildProperty Docs "$BuildRoot\docs"
)
#endregion  Path parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Clean phase parameters

$ExcludePathFromClean = (
    Get-BuildProperty ExcludePathFromClean @(
        "$(Get-BuildProperty Artifact)\modules*"
        "$(Get-BuildProperty Artifact)\logs*"
        "$(Get-BuildProperty Artifact)\backup*"
    ) )

#endregion Clean phase parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Validate phase parameters

$SkipDependencyCheck = (
    Get-BuildProperty SkipDependencyCheck $false
)

#endregion Validate phase parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Test phase parameters

$CodeCov = (
    Get-BuildProperty CodeCov $false
)


$CodeCovFormat = (
    Get-BuildProperty CodeCovFormat 'CoverageGutters'
)

$CodeCovPath = (
    Get-BuildProperty CodeCovPath (Join-Path $Artifact 'tests')
)


$CodeCovFile = (
    Get-BuildProperty CodeCovFile ("pester.{Type}.codecov.{Format}-$(Get-Date -Format FileDateTimeUniversal).xml")
)


$PesterOutput = (
    Get-BuildProperty PesterOutput 'Normal'
)

#endregion Test phase parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Build phase parameters

$CopyAdditionalItems = (
    Get-BuildProperty CopyAdditionalItems @{
        stitch = @{
            'Defaults.psd1'            = 'Defaults.psd1'
            'Import-BuildToolTask.ps1' = 'Import-BuildToolTask.ps1'
            'tasks'                    = 'tasks'
        }
    }
)

$CopyEmptySourceDirs = (
    Get-BuildProperty CopyEmptySourceDirs $false
)


$SkipManifestArrayFormat = (
    Get-BuildProperty SkipManifestArrayFormat @()
)



$ModuleFileIncludeTypes = (
    Get-BuildProperty ModuleFileIncludeTypes @('enum', 'class', 'function')
)

$ModuleFilePrefix = (
    Get-BuildProperty ModuleFilePrefix ''
)

$ModuleFileSuffix = (
    Get-BuildProperty ModuleFileSuffix 'suffix.ps1'
)


$ManifestBackupPath = (
    Get-BuildProperty ManifestBackupPath (Join-Path (Get-BuildProperty Artifact) 'backup')
)


$KeepManifestBackup = (
    Get-BuildProperty KeepManifestBackup $false
)

$ManifestVersionField = (
    Get-BuildProperty ManifestVersionField 'MajorMinorPatch'
)

$FormatPsXmlDirectory = (
    Get-BuildProperty FormatPsXmlDirectory 'formats'
)
$FormatPsXmlFileFilter = (
    Get-BuildProperty FormatPsXmlFileFilter '*Format.ps1xml'
)

$TypePsXmlDirectory = (
    Get-BuildProperty TypePsXmlDirectory 'types'
)

$TypePsXmlFileFilter = (
    Get-BuildProperty TypePsXmlFileFilter '*.Types.ps1xml'
)
#endregion Build phase parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Deploy phase parameters
$ReplaceVersionInFile = (
    Get-BuildProperty ReplaceVersionInFile @{
        Readme       = @{
            Path    = $BuildRoot
            Filter  = 'README.md'
            Find    = '^Version: .*'
            Replace = "Version: $($BuildInfo.Version.MajorMinorPatch)"
            Recurse = $false
        }
        MarkdownHelp = @{
            Path    = $BuildInfo.Docs
            Filter  = '*.md'
            Find    = 'Help Version: .*'
            Replace = "Help Version: $($BuildInfo.Version.MajorMinorPatch)"
            Recurse = $true
        }
    }
)


$ChangelogPath = (
    Get-BuildProperty ChangelogPath (Join-Path $BuildRoot 'CHANGELOG.md')
)


$ChangelogBackupPath = (
    Get-BuildProperty ChangelogBackupPath (Join-Path (Get-BuildProperty Artifact) 'backup')
)


$KeepChangelogBackup = (
    Get-BuildProperty KeepChangelogBackup $false
)

$ChangelogVersionField = (
    Get-BuildProperty ChangelogVersionField 'MajorMinorPatch'
)

$InstallSaveToPath = (
    Get-BuildProperty InstallSaveToPath (Resolve-Path ($env:PSModulePath -split ';' | Select-Object -First 1))
)

$InstallSaveToModules = (
    Get-BuildProperty InstallSaveToModules ((Get-BuildProperty BuildInfo).Modules.Keys)
)

$ProjectPSRepoName = (
    Get-BuildProperty ProjectPSRepoName $BuildInfo.Project.Name
)

$PublishToPsRepo = (
    Get-BuildProperty PublishToPsRepo 'local'
)

$GitTagVersionField = (
    Get-BuildProperty GitTagVersionField 'MajorMinorPatch'
)

#endregion Deploy phase parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Logging parameters
$LogPath = (Get-BuildProperty LogPath (Join-Path $Artifact 'logs'))

$LogFile = (Get-BuildProperty LogFile "build-$(Get-Date -Format FileDateTimeUniversal).log")

$Output = (
    Get-BuildProperty Output @{
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
#endregion Logging parameters
#-------------------------------------------------------------------------------
