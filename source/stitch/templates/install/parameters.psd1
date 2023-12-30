@{
    Parameters = [ordered]@{
        Profile = @(
            @{
                Group = 'Profile'
                Name = 'ProfilePath'
                Type = 'String'
                Default = '(Join-Path $BuildConfigRoot ''profiles'')'
                Help = @(
                    'The directory to search for runbooks'
                )
            }
            @{
                Name = 'BuildProfile'
                Type = 'String'
                Help = @(
                    'The lifecycle profile to run.  Determines which runbook will be loaded.'
                    'Runs the ``Build`` profile if none specified, or the single runbook if only one is found'
                )
                Alias = 'Profile'
                Group = 'Profile'
                Default = '''default'''
            }
            @{
                Group = 'Profile'
                Name = 'DefaultBuildProfile'
                Type = 'String'
                Default = '''default'''
                Help = @(
                    'The default BuildProfile if not specified (and more than one runbook exists)'
                )
            }
        )
        Path = @(
            @{
                Group = 'Path'
                Name = 'BuildConfigRoot'
                Type = 'String'
                Default = '(Join-Path $BuildRoot ''.build'')'
                Help = @(
                    'The base path to configuration and settings files'
                )
            }
            @{
                Group = 'Path'
                Name = 'BuildConfigFile'
                Type = 'String'
                Default = '''stitch.config.ps1'''
                Help = @(
                    'The file name of the configuration file'
                )
            }
            @{
                Group = 'Path'
                Name = 'Source'
                Type = 'String'
                Default = '(Join-Path $BuildRoot ''source'')'
                Help = @(
                    'The path to the source files for this project'
                )
            }
            @{
                Group = 'Path'
                Name = 'Staging'
                Type = 'String'
                Default = '(Join-Path $BuildRoot ''stage'')'
                Help = @(
                    'The path where the Build phase will stage the files it produces.'
                )
            }
            @{
                Group = 'Path'
                Name = 'Tests'
                Type = 'String'
                Default = '(Join-Path $BuildRoot ''tests'')'
                Help = @(
                    'The path to the Pester tests.'
                )
            }
            @{
                Group = 'Path'
                Name = 'Artifact'
                Type = 'String'
                Default = '(Join-Path $BuildRoot ''out'')'
                Help = @(
                    'The path to where build files and other artifacts (such as log files, supporting modules, etc.) are written'
                )
            }
            @{
                Group = 'Path'
                Name = 'Docs'
                Type = 'String'
                Default = '(Join-Path $BuildRoot ''docs'')'
                Help = @(
                    'The path where documentation (markdown help, etc.) is stored'
                )
            }
            @{
                Group = 'Path'
                Name = 'SourceTypeMap'
                Type = 'hashtable'
                Default = '@{
    # directory name => visibility
    ''public''     = @{ Visibility = ''public''; Type = ''function'' }
    ''class''      = @{ Visibility = ''private''; Type = ''class'' }
    ''classes''    = @{ Visibility = ''private''; Type = ''class'' }
    ''enum''       = @{ Visibility = ''private''; Type = ''enum'' }
    ''private''    = @{ Visibility = ''private''; Type = ''function'' }
    ''resource''   = @{ Visibility = ''private''; Type = ''resource'' }
    ''assembly''   = @{ Visibility = ''private''; Type = ''resource'' }
    ''assemblies'' = @{ Visibility = ''private''; Type = ''resource'' }
    ''data''       = @{ Visibility = ''private''; Type = ''resource'' }
}'
                Help = @(
                    'A table that maps source directory names to their types'
                    'for example :'
                    '@{ public = @{Visibility = ''public''; Type = ''function''}}'
                )
            }
        )
        Tasks = @(
            @{
                Group = 'Tasks'
                Name = 'SkipModuleTaskImport'
                Type = 'switch'
                Default = '$false'
                Help = @(
                    'Do not import tasks from the Stitch module.  This can be used to bypass the import for debug/testing purposes'
                )
            }
            @{
                Group = 'Tasks'
                Name = 'BuildInfo'
                Type = 'Hashtable'
                Default = '@{
    Modules = @{}
    Project = @{
        Name = ''''
    }
}'
                Help = @(
                    'The information related to the current project including Modules, Paths and Version information.  See Also Get-BuildConfiguration'
                )
            }
        )
        Clean = @(
            @{
                Group = 'Clean'
                Name = 'ExcludePathFromClean'
                Type = 'String[]'
                Default = '@( "$Artifact\logs*" , "$Artifact\backup*")'
                Help = @(
                    'Paths that should not be deleted when `Clean` is run.  By default everything in`$Staging` and `$Artifact` are removed'
                )
            }
        )
        Validate = @(
            @{
                Group = 'Validate'
                Name = 'SkipDependencyCheck'
                Type = 'switch'
                Default = '$false'
                Help = @(
                    'Do not check for module dependencies (PSDepend)'
                )
            }
            @{
                Group = 'Validate'
                Name = 'DependencyTags'
                Type = 'string[]'
                Default = '@()'
                Help = @(
                    'A list of tags to pass to PSDepend when installing requirements'
                )
            }
            @{
                Group = 'Validate'
                Name = 'RequiredModules'
                Type = 'hashtable'
                Default = '@{}'
                Help = 'A table of required modules with the Module name as the key and a hashtable with Version and Tag information (see requirements.psd1)'
            }
        )
        Test = @(
            @{
                Group = 'Test'
                Name = 'CodeCov'
                Type = 'switch'
                Default = '$false'
                Help = @(
                    'Produce codecoverage metrics when running Pester tests'
                )
            }
            @{
                Group = 'Test'
                Name = 'CodeCovFormat'
                Type = 'String'
                Default = 'CoverageGutters'
                Help = @(
                    'The format of the Code coverage output (CoverageGutters or JaCoCo)'
                )
            }
            @{
                Group = 'Test'
                Name = 'CodeCovDirectory'
                Type = 'String'
                Default = '(Join-Path $Artifact ''tests'')'
                Help = @(
                    'The Path to the directory where the Code Coverage output will be saved'
                )
            }
            @{
                Group = 'Test'
                Name = 'CodeCovFile'
                Type = 'String'
                Default = '"pester.{Type}.codecov.{Format}-$(Get-Date -Format FileDateTimeUniversal).xml"'
                Help = @(
                    'The name of the Code Coverage output file. Use {Type} and {Format} as replaceable fields'
                )
            }
            @{
                Group = 'Test'
                Name = 'TestResultFormat'
                Type = 'String'
                Default = 'NUnitXml'
                Help = @(
                    'The format of the Test result output (NUnitXml, Nunit2.5, or JUnitXml)'
                )
            }
            @{
                Group = 'Test'
                Name = 'TestResultDirectory'
                Type = 'String'
                Default = '(Join-Path $Artifact ''tests'')'
                Help = @(
                    'The Path to the directory where the Test result output will be saved'
                )
            }
            @{
                Group = 'Test'
                Name = 'TestResultFile'
                Type = 'String'
                Default = '"pester.{Type}.testresult.{Format}-$(Get-Date -Format FileDateTimeUniversal).xml"'
                Help = @(
                    'The name of the Test result output file. Use {Type} and {Format} as replaceable fields'
                )
            }
            @{
                Group = 'Test'
                Name = 'PesterOutput'
                Type = 'String'
                Default = '''Normal'''
                Help = @(
                    'The output level of Invoke-Pester'
                )
            }
            @{
                Group = 'Test'
                Name = 'PesterResultDirectory'
                Type = 'String'
                Default = '(Join-Path $Artifact ''tests'')'
                Help = @(
                    'The directory to store the Invoke-Pester result object'
                )
            }
            @{
                Group = 'Test'
                Name = 'PesterResultFile'
                Type = 'String'
                Default = '"pester.{Type}.result.-$(Get-Date -Format FileDateTimeUniversal).clixml"'
                Help = @(
                    'The file to store the Invoke-Pester result object'
                )
            }
        )
        Build = @(
            @{
                Group = 'Build'
                Name = 'CopyAdditionalItems'
                Type = 'Hashtable'
                Default = '@{}'
                Help = @(
                    'Additional paths in the `$Source` directory that should be copied to `$Staging`'
                    'Each key of this hashtable is a module name of your project whose value is a hashtable of Source = Staging paths'
                    'Specify paths relative to your module''s source directory on the left and one of three options on the right:'
                    '- a path relative to your module''s staging directory'
                    '- $true to use the same relative path'
                    '- $false to skip'
                    'Like'
                    '@{'
                    '    Module1 = @{'
                    '        data/configuration.data.psd1 = resources/config.psd1'
                    '    }'
                    '}'
                    'This will copy <source>/Module1/data/configuration.data.psd1 to <staging>/Module1/resources/config.psd1'
                )
            }
            @{
                Group = 'Build'
                Name = 'CopyEmptySourceDirs'
                Type = 'switch'
                Default = '$false'
                Help = @(
                    'Copy the directory even though it contains no items'
                )
            }
            @{
                Group = 'Build'
                Name = 'SkipManifestArrayFormat'
                Type = 'String[]'
                Default = '@()'
                Help = @(
                    'build.manifest.array.format task will update a manifest so that arrays are written with ''@('' and '')'' surrounding the list.  Fields listed here will be ignored in the manifest'
                )
            }
            @{
                Group = 'Build'
                Name = 'ModuleFileIncludeTypes'
                Type = 'String[]'
                Default = '@(''enum'', ''class'', ''function'')'
                Help = @(
                    'The list of source types to include in the module file (.psm1).'
                )
            }
            @{
                Group = 'Build'
                Name = 'ModuleFilePrefix'
                Type = 'String'
                Default = ''''''
                Help = @(
                    'Either a string or the path to a file whose contents will be inserted at the top of the Module file'
                    'Note that the content of the string is not automatically commented'
                )
            }
            @{
                Group = 'Build'
                Name = 'ModuleFileSuffix'
                Type = 'String'
                Default = ''''''
                Help = @(
                    'Either a string or the path to a file whose contents will be inserted at the bottom of the Module file'
                )
            }
            @{
                Group = 'Build'
                Name = 'ModuleNamespace'
                Type = 'hashtable'
                Default = '@{}'
                Help = @(
                    'If the module should be part of a larger namespace, set the namespace here.  ModuleNamespace is '
                    'a hashtable where the key is the module name and the value is the namespace like:'
                    '@{'
                    '    Module1 = ''Fabricam.Automation'''
                    '}'
                )
            }
            @{
                Group = 'Build'
                Name = 'ManifestBackupPath'
                Type = 'String'
                Default = '(Join-Path $Artifact ''backup'')'
                Help = @(
                    'Where to make backups of the source manifest prior to updating the version information'
                )
            }
            @{
                Group = 'Build'
                Name = 'KeepManifestBackup'
                Type = 'switch'
                Default = '$false'
                Help = @(
                    'Backups are deleted after being restored by default.  Use this flag to restore the changelog from the latest backup and keep the backup file'
                )
            }
            @{
                Group = 'Build'
                Name = 'ManifestVersionField'
                Type = 'String'
                Default = '''MajorMinorPatch'''
                Help = @(
                    'The gitversion field to use when setting the current version in the changelog'
                )
            }
            @{
                Group = 'Build'
                Name = 'SuppressManifestComments'
                Type = 'switch'
                Default = '$false'
                Help = @(
                    'Do not use New-ModuleManifest with parameters from the source, just copy directly'
                )
            }
            @{
                Group = 'Build'
                Name = 'ExcludeFunctionsFromExport'
                Type = 'string[]'
                Default = '@()'
                Help = @(
                    'Functions listed in this array will not be added to the FunctionsToExport array at build time'
                )
            }
            @{
                Group = 'Build'
                Name = 'ExcludeAliasFromExport'
                Type = 'string[]'
                Default = '@()'
                Help = @(
                    'Aliases listed in this array will not be added to the AliasesToExport array at build time'
                )
            }
            @{
                Group = 'Build'
                Name = 'FormatPsXmlDirectory'
                Type = 'String'
                Default = '''Formats'''
                Help = @(
                    'The source directory where PowerShell format files are stored (if any)'
                )
            }
            @{
                Group = 'Build'
                Name = 'FormatPsXmlFileFilter'
                Type = 'String'
                Default = '''*.Format.ps1xml'''
                Help = @(
                    'The file format used to find Format files in the source'
                )
            }
            @{
                Group = 'Build'
                Name = 'TypePsXmlDirectory'
                Type = 'String'
                Default = '''Types'''
                Help = @(
                    'The source directory where PowerShell type files are stored (if any)'
                )
            }
            @{
                Group = 'Build'
                Name = 'TypePsXmlFileFilter'
                Type = 'String'
                Default = '''*.Type.ps1xml'''
                Help = @(
                    'The file format used to find Format files in the sourcetypes'
                )
            }
            @{
                Group = 'Build'
                Name = 'HelpDocsCultureDirectory'
                Type = 'String'
                Default = '(Get-Culture | Select-Object -Expand Name)'
                Help = @(
                    'Set the name of the directory to export external help MAML file to'
                )
            }
            @{
                Group = 'Build'
                Name = 'HelpDocLogFile'
                Type = 'string'
                Default = '(Join-Path $Artifact "platyps_$(Get-Date -Format ''yyyy.MM.dd.HH.mm'').log")'
                Help = @(
                    'The path to a log file for the PlatyPS Update-MarkdownHelp command'
                )
            }
            @{
                Group = 'Build'
                Name = 'FormatSettings'
                Type = 'object'
                Default = '(Join-Path $BuildRoot "CodeFormatting.psd1")'
                Help = @(
                    'Settings for the Invoke-Formatter function'
                    'Either a path to a psd1 file or a hashtable of settings'
                )
            }
            @{
                Group = 'Build'
                Name = 'AnalyzerSettings'
                Type = 'object'
                Default = '(Join-Path $BuildRoot "PSScriptAnalyzerSetting.psd1")'
                Help = @(
                    'Settings for the Invoke-ScriptAnalyzer function'
                    'Either a path to a psd1 file or a hashtable of settings'
                )
            }
            @{
                Group = 'Build'
                Name = 'ProjectVersionSource'
                Type = 'string'
                Default = 'gitversion'
                Help = 'How to retrieve the version information.  Can be one of ''gitversion'', ''gitdescribe'' or ''file'''
            }
            @{
                Group = 'Build'
                Name = 'ProjectVersionField'
                Type = 'string'
                Default = 'MajorMinorPatch'
                Help = 'The field in the version info to use for the module version'
            }
        )
        Publish = @(
            @{
                Group = 'Publish'
                Name = 'ChangelogPath'
                Type = 'String'
                Default = '(Join-Path $BuildRoot ''CHANGELOG.md'')'
                Help = @(
                    'The path to the project''s changelog (if any)'
                )
            }
            @{
                Group = 'Publish'
                Name = 'ChangelogBackupPath'
                Type = 'String'
                Default = '(Join-Path $Artifact ''backup'')'
                Help = @(
                    'Where to make backups of the changlog prior to updating the version information'
                )
            }
            @{
                Group = 'Publish'
                Name = 'KeepChangelogBackup'
                Type = 'switch'
                Default = '$false'
                Help = @(
                    'Backups are deleted after being restored by default.  Use this flag to restore the changelog from the latest backup and keep the backup file'
                )
            }
            @{
                Group = 'Publish'
                Name = 'ChangelogVersionField'
                Type = 'String'
                Default = '''MajorMinorPatch'''
                Help = @(
                    'The gitversion field to use when setting the current version in the changelog'
                )
            }
            @{
                Group = 'Publish'
                Name = 'GitTagVersionField'
                Type = 'String'
                Default = '''MajorMinorPatch'''
                Help = @(
                    'The gitversion field to use when calling `git tag`'
                )
            }
            @{
                Group = 'Publish'
                Name = 'GitStashMessage'
                Type = 'String'
                Default = ''''''
                Help = @(
                    'An optional message to use when creating a git stash'
                )
            }
            @{
                Group = 'Publish'
                Name = 'IncludeUntrackedInGitStash'
                Type = 'switch'
                Default = '$false'
                Help = @(
                    'When creating a git stash, also stash untracked files'
                )
            }
            @{
                Group = 'Publish'
                Name = 'ProjectPSRepoName'
                Type = 'String'
                Default = '$BuildInfo.Project.Name'
                Help = @(
                    'The name of the temporary PSRepository to create when creating a nuget package'
                )
            }
            @{
                Group = 'Publish'
                Name = 'PublishPsRepoName'
                Type = 'String'
                Default = '''PSGallery'''
                Help = @(
                    'The name of the PSRepository to publish the module to'
                )
            }
            @{
                Group = 'Publish'
                Name = 'PublishToPsRepo'
                Type = 'String'
                Default = '''local'''
                Help = @(
                    'If publishing the module to a local PSRepository, add the name here'
                )
            }
            @{
                Group = 'Publish'
                Name = 'PublishActionIfUncommitted'
                Type = 'String'
                Default = '''local'''
                Help = @(
                    'What to do if publishing the module and there are uncommited changes'
                    '- stash : perform a git stash before continuing'
                    '- ignore : procede with publish task'
                    '- abort : fail the build'
                )
            }
            @{
                Name = 'NugetApiKey'
                Type = 'string'
                Group = 'Publish'
                Default = '(Get-Secret NugetApiKey -AsPlainText)'
                Help = @(
                    'The API key to use when publishing to PublishPsRepoName'
                )
            }
            @{
                Group = 'Publish'
                Name = 'ReleaseNotesFormat'
                Type = 'string'
                Default = 'text'
                Help = 'The format used for adding release notes to the manifest, can be one of ''text'' or ''url'''
            }
            @{
                Default = 'ReleaseNotes.md'
                Help = 'The path to the releasenotes file to use'
                Type = 'string'
                Group = 'Publish'
                Name = 'ReleaseNotesFile'
            }
        )
        Install = @(
            @{
                Group = 'Install'
                Name = 'InstallSaveToPath'
                Type = 'String'
                Default = '(Resolve-Path ($env:PSModulePath -split '';'' | Select-Object -First 1))'
                Help = @(
                    'Location to save the modules to (copy from staging) See the `install.module.saveto` task'
                )
            }
            @{
                Group = 'Install'
                Name = 'InstallSaveToModules'
                Type = 'String[]'
                Default = '$BuildInfo.Modules.Keys'
                Help = @(
                    'List of modules to save (all modules in project by default) See the `install.module.saveto` task'
                )
            }
            @{
                Group = 'Install'
                Name = 'InstallModuleFromPsRepo'
                Type = 'string'
                Default = '$BuildInfo.Project.Name'
                Help = @(
                    'When installing the project''s modules, use this repository as the source'
                )
            }
        )
        Logging = @(
            @{
                Group = 'Logging'
                Name = 'LogPath'
                Type = 'String'
                Default = '(Join-Path $Artifact ''logs'')'
                Help = @(
                    'The path to write the build log to. LogPath and LogFile are combined at runtime to determine the path to the build log'
                )
            }
            @{
                Group = 'Logging'
                Name = 'LogFile'
                Type = 'String'
                Default = '"build-$(Get-Date -Format FileDateTimeUniversal).log"'
                Help = @(
                    'The file name to write the build log to'
                )
            }
            @{
                Group = 'Logging'
                Name = 'Output'
                Type = 'Hashtable'
                Default = ' @{
        Timestamp         = @{
            Format          = ''%s''
            ForegroundColor = ''BrightWhite''
        }
        Console           = @{
            Enabled = $true
            Level   = ''DEBUG''
            Message = @{
                ForegroundColor = ''White''
            }
        }
        File              = @{
            Enabled = $false
            Level   = ''DEBUG''
        }
        5                 = @{
            ForegroundColor = ''BrightBlack''
            Label           = ''DEBUG''
        }
        4                 = @{
            ForegroundColor = ''Blue''
            Label           = ''INFO''
        }
        3                 = @{
            ForegroundColor = ''Yellow''
            Label           = ''WARN''
        }
        2                 = @{
            ForegroundColor = ''Red''
            Label           = ''ERROR''
        }
        ''clean.artifacts'' = ''INFO''
        ''clean.staging''   = ''INFO''
    }'
                Help = @(
                    'A table of output locations (Console and File), Levels (DEBUG, INFO, etc.) and other information that controls the output of the build'
                )
            }
            @{
                Group = 'Logging'
                Name = 'SkipBuildHeader'
                Type = 'switch'
                Default = '$false'
                Help = @(
                    'Suppress Build header and footer output'
                )
            }
        )
    }
}
