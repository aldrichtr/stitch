param(
    #-------------------------------------------------------------------------------
    #region BuildTool task import parameters
    [Parameter()][switch]$SkipModuleTaskImport = (
        property SkipModuleTaskImport $false
    ),

    [Parameter()]
    [hashtable]$BuildInfo = (
        property BuildInfo @{
            Modules = @{}
            Project = @{
                Name = 'stitch'
            }
        }
    ),
    #endregion BuildTool task import parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Profile
    # The lifecycle profile to run.  Determines which runbook will be loaded.
    # Runs the `Build` profile if none specified, or the single runbook if only
    # one is found
    [Parameter()][string]$Profile = 'build',

    # The regular expression to use to find runbooks
    [Parameter()][string]$ProfilePattern = '*runbook.ps1',

    # The directory to search for runbooks
    [Parameter()][string]$ProfilePath = '.build',

    #endregion Profile
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Path parameters
    [Parameter()]
    [string]$Source = (
        property Source "$BuildRoot\source"
    ),

    [Parameter()]
    [string]$Staging = (
        property Staging "$BuildRoot\stage"
    ),

    [Parameter()]
    [string]$Tests = (
        property Tests "$BuildRoot\tests"
    ),

    [Parameter()]
    [string]$Artifact = (
        property Artifact "$BuildRoot\out"
    ),

    [Parameter()]
    [string]$Docs = (
        property Docs "$BuildRoot\docs"
    ),
    #endregion [section] Path parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Clean phase parameters
    [Parameter()]
    [string[]]$ExcludePathFromClean = (
        property ExcludePathFromClean @(
            "$(property Artifact)\modules*",
            "$(property Artifact)\logs*",
            "$(property Artifact)\backup*"
        ) ),

    #endregion Clean phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Validate phase parameters
    [Parameter()]
    [switch]$SkipDependencyCheck = (
        property SkipDependencyCheck $false
    ),

    #endregion Validate phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Test phase parameters
    [Parameter()]
    [switch]$CodeCov = (
        property CodeCov $false
    ),

    [Parameter()]
    [string]$CodeCovFormat = (
        property CodeCovFormat 'CoverageGutters'
    ),
    [Parameter()]
    [string]$CodeCovPath = (
        property CodeCovPath (Join-Path $Artifact "tests")
    ),

    [Parameter()]
    [string]$CodeCovFile = (
        property CodeCovFile ("pester.{Type}.codecov.{Format}-$(Get-Date -Format FileDateTimeUniversal).xml")
    ),

    [Parameter()]
    [string]$PesterOutput = (
        property PesterOutput 'Normal'
    ),

    #endregion Test phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Build phase parameters
    [Parameter()]
    [hashtable]$CopyAdditionalItems = (
        property CopyAdditionalItems @{
            stitch = @{
                'Defaults.psd1'            = 'Defaults.psd1'
                'Import-BuildToolTask.ps1' = 'Import-BuildToolTask.ps1'
                'tasks'                    = 'tasks'
            }
        }
    ),

    [Parameter()]
    [switch]$CopyEmptySourceDirs = (
        property CopyEmptySourceDirs $false
    ),

    [Parameter()]
    [string[]]$SkipManifestArrayFormat = (
        property SkipManifestArrayFormat @()
    ),


    [Parameter()]
    [string[]]$ModuleFileIncludeTypes = (
        property ModuleFileIncludeTypes @('enum', 'class', 'function')
    ),

    [Parameter()][string]$ModuleFilePrefix = (
        property ModuleFilePrefix ''
    ),

    [Parameter()][string]$ModuleFileSuffix = (
        property ModuleFileSuffix 'suffix.ps1'
    ),

    [Parameter()]
    [string]$ManifestBackupPath = (
        property ManifestBackupPath (Join-Path (property Artifact) 'backup')
    ),

    [Parameter()]
    [switch]$KeepManifestBackup = (
        property KeepManifestBackup $false
    ),

    [Parameter()][string]$ManifestVersionField = (
        property ManifestVersionField 'MajorMinorPatch'
    ),

    [Parameter()][string]$FormatPsXmlDirectory = (
        property FormatPsXmlDirectory 'formats'
    ),
    [Parameter()][string]$FormatPsXmlFileFilter = (
        property FormatPsXmlFileFilter '*Format.ps1xml'
    ),

    [Parameter()][string]$TypePsXmlDirectory = (
        property TypePsXmlDirectory 'types'
    ),

    [Parameter()][string]$TypePsXmlFileFilter = (
        property TypePsXmlFileFilter '*.Types.ps1xml'
    ),
    #endregion Build phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Deploy phase parameters
    [Parameter()][hashtable]$ReplaceVersionInFile = (
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
    ),

    [Parameter()]
    [string]$ChangelogPath = (
        property ChangelogPath (Join-Path $BuildRoot 'CHANGELOG.md')
    ),

    [Parameter()]
    [string]$ChangelogBackupPath = (
        property ChangelogBackupPath (Join-Path (property Artifact) 'backup')
    ),

    [Parameter()]
    [switch]$KeepChangelogBackup = (
        property KeepChangelogBackup $false
    ),

    [Parameter()][string]$ChangelogVersionField = (
        property ChangelogVersionField 'MajorMinorPatch'
    ),



    [Parameter()]
    [string]$InstallSaveToPath = (
        property InstallSaveToPath (Resolve-Path ($env:PSModulePath -split ';' | Select-Object -First 1))
    ),

    [Parameter()]
    [string[]]$InstallSaveToModules = (
        property InstallSaveToModules ((property BuildInfo).Modules.Keys)
    ),

    [Parameter()][string]$ProjectPSRepoName = (
        property ProjectPSRepoName $BuildInfo.Project.Name
    ),

    [Parameter()][string]$PublishToPsRepo = (
        property PublishToPsRepo 'local'
    ),

    [Parameter()][string]$GitTagVersionField = (
        property GitTagVersionField 'MajorMinorPatch'
    ),

    #endregion Deploy phase parameters
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Logging parameters
    [Parameter()][string]$LogPath = (property LogPath (Join-Path $Artifact 'logs')),

    [Parameter()][string]$LogFile = (property LogFile "build-$(Get-Date -Format FileDateTimeUniversal).log"),

    [Parameter()][hashtable]$Output = (
        property Output @{
            Timestamp = @{
                Format = '%s'
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
)
