@{
    Parameters = [ordered]@{
        Profile  = @(
            @{
                Name    = 'ProfilePath'
                Type    = 'String'
                Help    = @('The directory to search for runbooks')
                Group   = 'Profile'
                Default = "(Join-Path `$BuildConfigRoot 'profiles')"
            }

            @{

                Name = 'BuildProfile'
                Alias = 'Profile'
                Type = 'String'
                Help = @(
                    'The lifecycle profile to run.  Determines which runbook will be loaded.',
                    'Runs the ``Build`` profile if none specified, or the single runbook if only one is found'
                    )
                Group = 'Profile'
                Default = "'default'"
            }

            @{
                Name    = 'DefaultBuildProfile'
                Type    = 'String'
                Help    = @('The default BuildProfile if not specified (and more than one runbook exists)')
                Group   = 'Profile'
                Default = "'default'"
            }
        )

        Path     = @(
            @{
                Name    = 'BuildConfigRoot'
                Type    = 'String'
                Help    = @('The base path to configuration and settings files')
                Group   = 'Path'
                Default = "(Join-Path `$BuildRoot '.build')"
            }


            @{
                Name    = 'BuildConfigFile'
                Type    = 'String'
                Help    = @('The file name of the configuration file')
                Group   = 'Path'
                Default = "'stitch.config.ps1'"
            }

            @{
                Name    = 'Source'
                Type    = 'String'
                Help    = @('The path to the source files for this project')
                Group   = 'Path'
                Default = "(Join-Path `$BuildRoot 'source')"
            }

            @{
                Name    = 'Staging'
                Type    = 'String'
                Help    = @('The path where the Build phase will stage the files it produces.')
                Group   = 'Path'
                Default = "(Join-Path `$BuildRoot 'stage')"
            }

            @{
                Name    = 'Tests'
                Type    = 'String'
                Help    = @('The path to the Pester tests.')
                Group   = 'Path'
                Default = "(Join-Path `$BuildRoot 'tests')"
            }

            @{
                Name    = 'Artifact'
                Type    = 'String'
                Help    = @('The path to where build files and other artifacts (such as log files, supporting modules, etc.) are written')
                Group   = 'Path'
                Default = "(Join-Path `$BuildRoot 'out')"
            }

            @{
                Name    = 'Docs'
                Type    = 'String'
                Help    = @('The path where documentation (markdown help, etc.) is stored')
                Group   = 'Path'
                Default = "(Join-Path `$BuildRoot 'docs')"
            }

            @{
                Name    = 'SourceTypeMap'
                Type    = 'hashtable'
                Help    = @(
                    'A table that maps source directory names to their types',
                    'for example :',
                    "@{ public = @{Visibility = 'public'; Type = 'function'}}"
                )
                Group   = 'Path'
                Default = @'
@{
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
'@
            }
        )

        Tasks    = @(
            @{
                Name    = 'SkipModuleTaskImport'
                Type    = 'switch'
                Help    = @('Do not import tasks from the Stitch module.  This can be used to bypass the import for debug/testing purposes')
                Group   = 'Tasks'
                Default = '$false'
            }

            @{
                Name    = 'BuildInfo'
                Type    = 'Hashtable'
                Help    = @('The information related to the current project including Modules, Paths and Version information.  See Also Get-BuildConfiguration')
                Group   = 'Tasks'
                Default = @'
@{
    Modules = @{}
    Project = @{
        Name = ''
    }
}
'@
            }
        )

        Clean    = @(
            @{
                Name    = 'ExcludePathFromClean'
                Type    = 'String[]'
                Help    = @('Paths that should not be deleted when `Clean` is run.  By default everything in`$Staging` and `$Artifact` are removed')
                Group   = 'Clean'
                Default = '@( "$Artifact\logs*" , "$Artifact\backup*")'
            }
        )

        Validate = @(
            @{
                Name    = 'SkipDependencyCheck'
                Type    = 'switch'
                Help    = @('Do not check for module dependencies (PSDepend)')
                Group   = 'Validate'
                Default = '$false'
            }

            @{
                Name    = 'DependencyTags'
                Type    = 'string[]'
                Help    = @('A list of tags to pass to PSDepend when installing requirements')
                Group   = 'Validate'
                Default = '@()'
            }
        )

        Test     = @(
            @{
                Name    = 'CodeCov'
                Type    = 'switch'
                Help    = @('Produce codecoverage metrics when running Pester tests')
                Group   = 'Test'
                Default = '$false'
            }

            @{
                Name    = 'CodeCovFormat'
                Type    = 'String'
                Help    = @('The format of the Code coverage output (CoverageGutters or JaCoCo)')
                Group   = 'Test'
                Default = 'CoverageGutters'
            }

            @{
                Name    = 'CodeCovDirectory'
                Type    = 'String'
                Help    = @('The Path to the directory where the Code Coverage output will be saved')
                Group   = 'Test'
                Default = "(Join-Path `$Artifact 'tests')"
            }

            @{
                Name    = 'CodeCovFile'
                Type    = 'String'
                Help    = @('The name of the Code Coverage output file. Use {Type} and {Format} as replaceable fields')
                Group   = 'Test'
                Default = "`"pester.{Type}.codecov.{Format}-`$(Get-Date -Format FileDateTimeUniversal).xml`""
            }

            @{
                Name    = 'TestResultFormat'
                Type    = 'String'
                Help    = @('The format of the Test result output (NUnitXml, Nunit2.5, or JUnitXml)')
                Group   = 'Test'
                Default = 'NUnitXml'
            }

            @{
                Name    = 'TestResultDirectory'
                Type    = 'String'
                Help    = @('The Path to the directory where the Test result output will be saved')
                Group   = 'Test'
                Default = "(Join-Path `$Artifact 'tests')"
            }

            @{
                Name    = 'TestResultFile'
                Type    = 'String'
                Help    = @('The name of the Test result output file. Use {Type} and {Format} as replaceable fields')
                Group   = 'Test'
                Default = "`"pester.{Type}.testresult.{Format}-`$(Get-Date -Format FileDateTimeUniversal).xml`""
            }

            @{
                Name    = 'PesterOutput'
                Type    = 'String'
                Help    = @('The output level of Invoke-Pester')
                Group   = 'Test'
                Default = "'Normal'"
            }

            @{
                Name    = 'PesterResultDirectory'
                Type    = 'String'
                Help    = @('The directory to store the Invoke-Pester result object')
                Group   = 'Test'
                Default = "(Join-Path `$Artifact 'tests')"
            }

            @{
                Name    = 'PesterResultFile'
                Type    = 'String'
                Help    = @('The file to store the Invoke-Pester result object')
                Group   = 'Test'
                Default = "`"pester.{Type}.result.-`$(Get-Date -Format FileDateTimeUniversal).clixml`""
            }
        )

        Build    = @(
            @{
                Name    = 'CopyAdditionalItems'
                Type    = 'Hashtable'
                Help    = @('Additional paths in the `$Source` directory that should be copied to `$Staging`',
                    'Each key of this hashtable is a module name of your project whose value is a hashtable of Source = Staging paths',
                    "Specify paths relative to your module's source directory on the left and one of three options on the right:",
                    "- a path relative to your module's staging directory",
                    "- `$true to use the same relative path",
                    "- `$false to skip"
                    'Like',
                    '@{',
                    '    Module1 = @{',
                    '        data/configuration.data.psd1 = resources/config.psd1',
                    '    }',
                    '}',
                    'This will copy <source>/Module1/data/configuration.data.psd1 to <staging>/Module1/resources/config.psd1'
                )
                Group   = 'Build'
                Default = '@{}'
            }

            @{
                Name    = 'CopyEmptySourceDirs'
                Type    = 'switch'
                Help    = @('Copy the directory even though it contains no items')
                Group   = 'Build'
                Default = '$false'
            }

            @{
                Name    = 'SkipManifestArrayFormat'
                Type    = 'String[]'
                Help    = @("build.manifest.array.format task will update a manifest so that arrays are written with '@(' and ')' surrounding the list.  Fields listed here will be ignored in the manifest")
                Group   = 'Build'
                Default = '@()'
            }

            @{
                Name    = 'ModuleFileIncludeTypes'
                Type    = 'String[]'
                Help    = @('The list of source types to include in the module file (.psm1).')
                Group   = 'Build'
                Default = "@('enum', 'class', 'function')"
            }

            @{
                Name    = 'ModuleFilePrefix'
                Type    = 'String'
                Help    = @(
                    'Either a string or the path to a file whose contents will be inserted at the top of the Module file',
                    'Note that the content of the string is not automatically commented'
                )
                Group   = 'Build'
                Default = "''"
            }

            @{
                Name    = 'ModuleFileSuffix'
                Type    = 'String'
                Help    = @('Either a string or the path to a file whose contents will be inserted at the bottom of the Module file')
                Group   = 'Build'
                Default = "''"
            }

            @{
                Name    = 'ModuleNamespace'
                Type    = 'hashtable'
                Help    = @('If the module should be part of a larger namespace, set the namespace here.  ModuleNamespace is ',
                    'a hashtable where the key is the module name and the value is the namespace like:',
                    '@{',
                    "    Module1 = 'Fabricam.Automation'",
                    '}')
                Group   = 'Build'
                Default = '@{}'
            }

            @{
                Name    = 'ManifestBackupPath'
                Type    = 'String'
                Help    = @('Where to make backups of the source manifest prior to updating the version information')
                Group   = 'Build'
                Default = "(Join-Path `$Artifact 'backup')"
            }

            @{
                Name    = 'KeepManifestBackup'
                Type    = 'switch'
                Help    = @('Backups are deleted after being restored by default.  Use this flag to restore the changelog from the latest backup and keep the backup file')
                Group   = 'Build'
                Default = '$false'
            }

            @{
                Name    = 'ManifestVersionField'
                Type    = 'String'
                Help    = @('The gitversion field to use when setting the current version in the changelog')
                Group   = 'Build'
                Default = "'MajorMinorPatch'"
            }

            @{
                Name    = 'SuppressManifestComments'
                Type    = 'switch'
                Help    = @('Do not use New-ModuleManifest with parameters from the source, just copy directly')
                Group   = 'Build'
                Default = '$false'
            }

            @{
                Name    = 'ExcludeFunctionsFromExport'
                Type    = 'string[]'
                Help    = @('Functions listed in this array will not be added to the FunctionsToExport array at build time')
                Group   = 'Build'
                Default = '@()'
            }

            @{
                Name    = 'ExcludeAliasFromExport'
                Type    = 'string[]'
                Help    = @('Aliases listed in this array will not be added to the AliasesToExport array at build time')
                Group   = 'Build'
                Default = '@()'
            }

            @{
                Name    = 'FormatPsXmlDirectory'
                Type    = 'String'
                Help    = @('The source directory where PowerShell format files are stored (if any)')
                Group   = 'Build'
                Default = "'Formats'"
            }

            @{
                Name    = 'FormatPsXmlFileFilter'
                Type    = 'String'
                Help    = @('The file format used to find Format files in the source')
                Group   = 'Build'
                Default = "'*.Format.ps1xml'"
            }

            @{
                Name    = 'TypePsXmlDirectory'
                Type    = 'String'
                Help    = @('The source directory where PowerShell type files are stored (if any)')
                Group   = 'Build'
                Default = "'Types'"
            }

            @{
                Name    = 'TypePsXmlFileFilter'
                Type    = 'String'
                Help    = @('The file format used to find Format files in the sourcetypes')
                Group   = 'Build'
                Default = "'*.Type.ps1xml'"
            }

            @{
                Name    = 'HelpDocsCultureDirectory'
                Type    = 'String'
                Help    = @('Set the name of the directory to export external help MAML file to')
                Group   = 'Build'
                Default = '(Get-Culture | Select-Object -Expand Name)'
            }

            @{
                Name    = 'HelpDocLogFile'
                Type    = 'string'
                Help    = @('The path to a log file for the PlatyPS Update-MarkdownHelp command')
                Group   = 'Build'
                Default = '(Join-Path $Artifact "platyps_$(Get-Date -Format ''yyyy.MM.dd.HH.mm'').log")'
            }

            @{
                Name    = 'FormatSettings'
                Type    = 'object'
                Help    = @('Settings for the Invoke-Formatter function',
                            'Either a path to a psd1 file or a hashtable of settings')
                Group   = 'Build'
                Default = '(Join-Path $BuildRoot "CodeFormatting.psd1")'
            }

            @{
                Name    = 'AnalyzerSettings'
                Type    = 'object'
                Help    = @('Settings for the Invoke-ScriptAnalyzer function',
                            'Either a path to a psd1 file or a hashtable of settings')
                Group   = 'Build'
                Default = '(Join-Path $BuildRoot "PSScriptAnalyzerSetting.psd1")'
            }
        )

        Publish  = @(
            @{
                Name    = 'ChangelogPath'
                Type    = 'String'
                Help    = @("The path to the project's changelog (if any)")
                Group   = 'Publish'
                Default = "(Join-Path `$BuildRoot 'CHANGELOG.md')"
            }

            @{
                Name    = 'ChangelogBackupPath'
                Type    = 'String'
                Help    = @('Where to make backups of the changlog prior to updating the version information')
                Group   = 'Publish'
                Default = "(Join-Path `$Artifact 'backup')"
            }

            @{
                Name    = 'KeepChangelogBackup'
                Type    = 'switch'
                Help    = @('Backups are deleted after being restored by default.  Use this flag to restore the changelog from the latest backup and keep the backup file')
                Group   = 'Publish'
                Default = '$false'
            }

            @{
                Name    = 'ChangelogVersionField'
                Type    = 'String'
                Help    = @('The gitversion field to use when setting the current version in the changelog')
                Group   = 'Publish'
                Default = "'MajorMinorPatch'"
            }

            @{
                Name    = 'GitTagVersionField'
                Type    = 'String'
                Help    = @('The gitversion field to use when calling `git tag`')
                Group   = 'Publish'
                Default = "'MajorMinorPatch'"
            }

            @{
                Name    = 'GitStashMessage'
                Type    = 'String'
                Help    = @('An optional message to use when creating a git stash')
                Group   = 'Publish'
                Default = "''"
            }

            @{
                Name    = 'IncludeUntrackedInGitStash'
                Type    = 'switch'
                Help    = @('When creating a git stash, also stash untracked files')
                Group   = 'Publish'
                Default = "`$false"
            }

            @{
                Name    = 'ProjectPSRepoName'
                Type    = 'String'
                Help    = @('The name of the temporary PSRepository to create when creating a nuget package')
                Group   = 'Publish'
                Default = "`$BuildInfo.Project.Name"
            }

            @{
                Name    = 'PublishPsRepoName'
                Type    = 'String'
                Help    = @('The name of the PSRepository to publish the module to')
                Group   = 'Publish'
                Default = "'PSGallery'"
            }

            @{
                Name    = 'PublishToPsRepo'
                Type    = 'String'
                Help    = @('If publishing the module to a local PSRepository, add the name here')
                Group   = 'Publish'
                Default = "'local'"
            }

            @{
                Name    = 'PublishActionIfUncommitted'
                Type    = 'String'
                Help    = @(
                    'What to do if publishing the module and there are uncommited changes',
                    '- stash : perform a git stash before continuing',
                    '- ignore : procede with publish task',
                    '- abort : fail the build'
                )
                Group   = 'Publish'
                Default = "'local'"
            }

            @{
                Name    = 'NugetApiKey'
                Type    = 'string'
                Help    = @( 'The API key to use when publishing to PublishPsRepoName')
                Default = '(Get-Secret NugetApiKey -AsPlainText)'
            }
        )

        Install  = @(
            @{
                Name    = 'InstallSaveToPath'
                Type    = 'String'
                Help    = @('Location to save the modules to (copy from staging) See the `install.module.saveto` task')
                Group   = 'Install'
                Default = "(Resolve-Path (`$env:PSModulePath -split ';' | Select-Object -First 1))"
            }

            @{
                Name    = 'InstallSaveToModules'
                Type    = 'String[]'
                Help    = @('List of modules to save (all modules in project by default) See the `install.module.saveto` task')
                Group   = 'Install'
                Default = "`$BuildInfo.Modules.Keys"
            }

            @{
                Name    = 'InstallModuleFromPsRepo'
                Type    = 'string'
                Help    = @('When installing the project''s modules, use this repository as the source')
                Group   = 'Install'
                Default = "`$BuildInfo.Project.Name"
            }

        )

        Logging  = @(
            @{
                Name    = 'LogPath'
                Type    = 'String'
                Help    = @('The path to write the build log to. LogPath and LogFile are combined at runtime to determine the path to the build log')
                Group   = 'Logging'
                Default = "(Join-Path `$Artifact 'logs')"
            }

            @{
                Name    = 'LogFile'
                Type    = 'String'
                Help    = @('The file name to write the build log to')
                Group   = 'Logging'
                Default = "`"build-`$(Get-Date -Format FileDateTimeUniversal).log`""
            }

            @{
                Name    = 'Output'
                Type    = 'Hashtable'
                Help    = @('A table of output locations (Console and File), Levels (DEBUG, INFO, etc.) and other information that controls the output of the build')
                Group   = 'Logging'
                Default = @'
 @{
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
'@
            }

            @{
                Name    = 'SkipBuildHeader'
                Type    = 'switch'
                Help    = @('Suppress Build header and footer output')
                Group   = 'Logging'
                Default = '$false'
            }
        )
    }
}
