
function Get-BuildConfiguration {
    <#
    .SYNOPSIS
        Gather information about the project for use in tasks
    .DESCRIPTION
        `Get-BuildConfiguration` collects information about paths, source items, versions and modules that it finds
        in -Path.  Configuration information can be added/updated using configuration files.
    .EXAMPLE
        Get-BuildConfiguration . -ConfigurationFiles ./.build/config
        gci .build\config | Get-BuildConfiguration .
    #>
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    [CmdletBinding()]
    param (
        # Specifies a path to the folder to build the configuration for
        [Parameter(
            Position = 0,
            ValueFromPipelineByPropertyName
        )]
        [string]$Path = (Get-Location),

        # Path to the build configuration file
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$ConfigurationFiles,

        # Default Source directory
        [Parameter(
        )]
        [string]$Source = '.\source',

        # Default Tests directory
        [Parameter(
        )]
        [string]$Tests = '.\tests',

        # Default Staging directory
        [Parameter(
        )]
        [string]$Staging = '.\stage',

        # Default Artifact directory
        [Parameter(
        )]
        [string]$Artifact = '.\out',

        # Default Docs directory
        [Parameter(
        )]
        [string]$Docs = '.\docs'
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        #-------------------------------------------------------------------------------
        #region Set defaults

        # Where to look for configuration files if the -ConfigurationFiles parameter is empty
        $configurationFileDefaults = @{
            Path   = '.\build\config\build'
            Filter = '*.config.ps1'
        }

        function loadConfiguration {
            param(
                [string]$Location,
                [OrderedDictionary]$Table
            )
            if (Test-Path $Location) {
                $locationItem = Get-Item $Location
                if ( $locationItem.PSISContainer) {
                    Write-Debug "  $Location is a directory.  Looking in location for files"
                    Get-ChildItem $Location | ForEach-Object {
                        $Table = loadConfiguration -Path $_.FullName -Table $Table
                    }
                    $Table = loadConfiguration -Path $Location.FullName -Table $Table
                } elseif ($locationItem.Name -like $configurationFileDefaults.Filter) {
                    Write-Verbose "  Loading $($locationItem.Name) into configuration"
                    if ($Table.Keys.Count -eq 0) {
                        Write-Debug "   Creating configuration from $($locationItem.Name)"
                        $Table = Import-Psd $locationItem.FullName
                    } else {
                        Write-Debug "   Updating configuration from $($locationItem.Name)"
                        $null = $Table | Update-Object (Import-Psd $location.FullName)

                    }
                } else {
                    Write-Verbose "    $Location does not match config filter"
                }
            } else {
                Write-Verbose "$Location is not a valid File or Directory"
            }
            $Table | Write-Output
        }

        # The info table holds all of the gathered project information
        $info = [ordered]@{
            Source   = (Join-Path $Path $Source)
            Tests    = (Join-Path $Path $Tests)
            Staging  = (Join-Path $Path $Staging)
            Artifact = (Join-Path $Path $Artifact)
            Docs     = (Join-Path $Path $Docs)
            Project  = @{}
        }
        #endregion Set defaults
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Version info

        Write-Debug 'Checking for version information'
        Write-Debug '  - Checking for gitversion utility'
        $gitverCmd = Get-Command dotnet-gitversion.exe -ErrorAction SilentlyContinue

        if ($null -eq $gitverCmd) {
            Write-Information "GitVersion is not installed.`nsee <https://gitversion.net/docs/usage/cli/installation> for details"
            Write-Debug '    - gitversion not found'
            Write-Debug '  - Looking for version.* file'
            $found = Get-ChildItem -Path $Path -Filter 'version.*' -Recurse |
                Sort-Object LastWriteTime |
                    Select-Object -Last 1

            if ($null -ne $found) {
                Write-Debug "    - Found $($found.FullName)"
                switch -Regex ($found.extension) {
                    'psd1' { $versionInfo = Import-Psd $found }
                    'json' { $versionInfo = (Get-Content $found | ConvertFrom-Json) }
                    'y(a)?ml' { $versionInfo = (Get-Content $found | ConvertFrom-Yaml) }
                    Default { Write-Information "$($found.Name) found but no converter for $($found.extension) is set" }
                }
            } else {
                Write-Debug "    - No version files found in $Path"
            }
        } else {
            Write-Debug '  - gitversion found.  Getting version info'
            $versionInfo = & $gitverCmd @('/nofetch', '/output', 'json') | ConvertFrom-Json
        }
        if ($null -ne $versionInfo) {
            Write-Debug "Setting 'Version' key with version info"
            $info.Project['Version'] = $versionInfo
        } else {
            Write-Debug 'No version information found in project'
        }

        #endregion Version info
        #-------------------------------------------------------------------------------
    }
    process {
        if ($PSBoundParameters.ContainsKey('ConfigurationFiles')) {
            foreach ($f in $ConfigurationFiles) {
                $info = loadConfiguration -Location $f -Table $info
            } else {
                $defaultConfig = (Join-Path $Path $configurationFileDefaults.Path)
                if (Test-Path $defaultConfig) {
                    $info = loadConfiguration -Location $defaultConfig -Table $info
                }
            }

        }
    }
    end {
        try {
            Write-Debug 'Resolving project root'
            $resolveRootOptions = @{
                Path     = $Path
                Source   = $Source
                Tests    = $Tests
                Staging  = $Staging
                Artifact = $Artifact
                Docs     = $Docs

            }
            $root = (Get-Item (Resolve-ProjectRoot @resolveRootOptions -ErrorAction SilentlyContinue))

        } catch {
            Write-Warning "Could not find Project Root`n$_"
        }

        if ($null -ne $root) {
            Write-Debug '  - root found:'
            Write-Debug "    - Path is : $($root.FullName)"
            Write-Debug "    - Name is : $($root.BaseName)"

            $info['Project'] = @{
                Path = $root.FullName
                Name = $root.BaseName
            }
        } else {
            Write-Debug " - Project root was not found. 'Path' and 'Name' will be empty"
            $info['Project'] = @{
                Path = ''
                Name = ''
            }
        }

        $info['Modules'] = @{}

        Write-Debug "  Loading modules from $($info.Source)"
        foreach ($item in (Get-ModuleItem $info.Source)) {
            Write-Debug "  Adding $($item.Name) to the collection"
            #! Get the names of the paths to process from failsafe_defaults, but the
            #! values come from the info table
            $item | Add-Member -NotePropertyName Paths -NotePropertyValue ($failsafe_defaults.Keys)
            foreach ($key in $failsafe_defaults.Keys) {
                $item | Add-Member -NotePropertyName $key -NotePropertyValue (Join-Path $info[$key] $item.Name)
            }
            $info.Modules[$item.Name] = $item
        }

        <#------------------------------------------------------------------
              Now, configure the directories for each module.  If a module is
              a Nested Module of another, then the staging folder should be:
              $Staging/RootModuleName/NestedModuleName
            ------------------------------------------------------------------#>

        Write-Debug "$('-' * 80)`n   --- Getting NestedModules"
        foreach ($key in $info.Modules.Keys) {
            $currentModule = $info.Modules[$key]
            if ($null -ne $currentModule.NestedModules) {
                foreach ($nest in $currentModule.NestedModules) {
                    if ($nest -is [string]) {
                        $nestedModule = $nest
                    } elseif ($nest -is [hashtable]) {
                        $nestedModule = $nest.ModuleName
                    }
                    Write-Debug "  Nested module: $nestedModule"
                    $found = ''
                    switch -Regex ($nestedModule) {
                        # path\to\ModuleName.psm1
                        # path/to/ModuleName.psm1
                        '[\\/]?(?<fname>)\.psm1$' {
                            Write-Debug "  - Found path to module file $($Matches.fname)"
                            $found = $Matches.fname
                            continue
                        }
                        # path\to\ModuleName
                        # path/to/ModuleName
                        '(\w+[\\/])*(?<lword>\w+)$' {
                            Write-Debug "  - Found path to directory $($Matches.lword)"
                            $found = $Matches.lword
                            continue
                        }
                        Default {
                            Write-Debug '  - Does not match a pattern'
                            $found = $nestedModule
                        }
                    }
                    if ($info.Modules.Keys -contains $found) {
                        Write-Debug "  Adding $($currentModule.Name) as parent of $found"
                        $info.Modules[$found] | Add-Member -NotePropertyName 'Parent' -NotePropertyValue $currentModule.Name
                    } else {
                        Write-Debug " $found not found in project's modules`n$($info.Modules.Keys -join "`n - ") "
                    }
                }
            }
        }

        $info | Write-Output
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
