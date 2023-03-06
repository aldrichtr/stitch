

#-------------------------------------------------------------------------------
#region BuildTool task import parameters
$SkipModuleTaskImport = (
    property SkipModuleTaskImport $false
)


$BuildInfo = (
    property BuildInfo @{
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
    property Source "$BuildRoot\source"
)


$Staging = (
    property Staging "$BuildRoot\stage"
)


$Tests = (
    property Tests "$BuildRoot\tests"
)


$Artifact = (
    property Artifact "$BuildRoot\out"
)


$Docs = (
    property Docs "$BuildRoot\docs"
)
#endregion  Path parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Clean phase parameters

$ExcludePathFromClean = (
    property ExcludePathFromClean @(
        "$(property Artifact)\modules*"
        "$(property Artifact)\logs*"
        "$(property Artifact)\backup*"
    ) )

#endregion Clean phase parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Validate phase parameters

$SkipDependencyCheck = (
    property SkipDependencyCheck $false
)

#endregion Validate phase parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Test phase parameters

$CodeCov = (
    property CodeCov $false
)


$CodeCovFormat = (
    property CodeCovFormat 'CoverageGutters'
)

$CodeCovPath = (
    property CodeCovPath (Join-Path $Artifact 'tests')
)


$CodeCovFile = (
    property CodeCovFile ("pester.{Type}.codecov.{Format}-$(Get-Date -Format FileDateTimeUniversal).xml")
)


$PesterOutput = (
    property PesterOutput 'Normal'
)

#endregion Test phase parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Build phase parameters

$CopyAdditionalItems = (
    property CopyAdditionalItems @{
        stitch = @{
            'Defaults.psd1'            = 'Defaults.psd1'
            'Import-BuildToolTask.ps1' = 'Import-BuildToolTask.ps1'
            'tasks'                    = 'tasks'
        }
    }
)

$CopyEmptySourceDirs = (
    property CopyEmptySourceDirs $false
)


$SkipManifestArrayFormat = (
    property SkipManifestArrayFormat @()
)



$ModuleFileIncludeTypes = (
    property ModuleFileIncludeTypes @('enum', 'class', 'function')
)

$ModuleFilePrefix = (
    property ModuleFilePrefix ''
)

$ModuleFileSuffix = (
    property ModuleFileSuffix 'suffix.ps1'
)


$ManifestBackupPath = (
    property ManifestBackupPath (Join-Path (property Artifact) 'backup')
)


$KeepManifestBackup = (
    property KeepManifestBackup $false
)

$ManifestVersionField = (
    property ManifestVersionField 'MajorMinorPatch'
)

$FormatPsXmlDirectory = (
    property FormatPsXmlDirectory 'formats'
)
$FormatPsXmlFileFilter = (
    property FormatPsXmlFileFilter '*Format.ps1xml'
)

$TypePsXmlDirectory = (
    property TypePsXmlDirectory 'types'
)

$TypePsXmlFileFilter = (
    property TypePsXmlFileFilter '*.Types.ps1xml'
)
#endregion Build phase parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Deploy phase parameters
$ReplaceVersionInFile = (
    property ReplaceVersionInFile @{
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
    property ChangelogPath (Join-Path $BuildRoot 'CHANGELOG.md')
)


$ChangelogBackupPath = (
    property ChangelogBackupPath (Join-Path (property Artifact) 'backup')
)


$KeepChangelogBackup = (
    property KeepChangelogBackup $false
)

$ChangelogVersionField = (
    property ChangelogVersionField 'MajorMinorPatch'
)

$InstallSaveToPath = (
    property InstallSaveToPath (Resolve-Path ($env:PSModulePath -split ';' | Select-Object -First 1))
)

$InstallSaveToModules = (
    property InstallSaveToModules ((property BuildInfo).Modules.Keys)
)

$ProjectPSRepoName = (
    property ProjectPSRepoName $BuildInfo.Project.Name
)

$PublishToPsRepo = (
    property PublishToPsRepo 'local'
)

$GitTagVersionField = (
    property GitTagVersionField 'MajorMinorPatch'
)

#endregion Deploy phase parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Logging parameters
$LogPath = (property LogPath (Join-Path $Artifact 'logs'))

$LogFile = (property LogFile "build-$(Get-Date -Format FileDateTimeUniversal).log")

$Output = (
    property Output @{
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
