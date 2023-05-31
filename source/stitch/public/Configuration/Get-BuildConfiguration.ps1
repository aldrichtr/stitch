
using namespace System.Collections.Specialized
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
    param(
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
        [string]$Source,

        # Default Tests directory
        [Parameter(
        )]
        [string]$Tests,

        # Default Staging directory
        [Parameter(
        )]
        [string]$Staging,

        # Default Artifact directory
        [Parameter(
        )]
        [string]$Artifact,

        # Default Docs directory
        [Parameter(
        )]
        [string]$Docs
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        # The info table holds all of the gathered project information, which will ultimately be returned to the
        # caller
        $info = [ordered]@{
            Project = @{}
        }

        #-------------------------------------------------------------------------------
        #region Set defaults

        <#
         !used throughout to set "project locations"
         which is why we don't just add it directly to $info
        #>
        $defaultLocations = @{
            Source   = "source"
            Tests    = 'tests'
            Staging  = 'stage'
            Artifact = 'out'
            Docs     = 'docs'
        }

        # Add them as top level keys
        $defaultLocations.Keys | ForEach-Object { $info[$_] = '' }

        #endregion Set defaults
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Normalize paths

        Write-Debug ( @(
                "Paths used to build configuration:",
                "Path     : $Path",
                "Source   : $Source",
                "Staging  : $Staging",
                "Artifact : $Artifact",
                "Tests    : $Tests",
                "Docs     : $Docs") -join "`n")

        $possibleRoot = $PSCmdlet.GetVariableValue('BuildRoot')
        if ($null -eq $possibleRoot) {
            Write-Debug "`$BuildRoot not found, using current location"
            $possibleRoot = (Get-Location)
        }

        foreach ($location in $defaultLocations.Keys) {
            Write-Debug "Setting the $location path"
            <#
                     The paths to the individual locations are vital to the correct operation of
                     the build.
                     Each variable is checked to see if it exists as a parameter, and then in the
                      caller scope (set via the script that called this function).
                      Finally, we test to see if the "default" is true, and add it
                    #>

            if ($PSBoundParameters.ContainsKey($location)) {
                $possibleLocation = $PSBoundParameters[$location]
            } elseif ($PSCmdlet.GetVariableValue($location)) {
                $possibleLocation = $PSCmdlet.GetVariableValue($location)
            } else {
                $possibleLocation = $defaultLocations[$location]
            }

            if ($null -ne $possibleLocation) {
                if (-not([System.IO.Path]::IsPathFullyQualified($possibleLocation))) {
                    $possibleLocation = (Join-Path $possibleRoot $possibleLocation)
                }

                if (-not(Test-Path $possibleLocation)) {
                    Write-Warning "$possibleLocation set as `$$location, but path does not exist"
                }
                #? Not sure what the right action is here.  I could fail the function
                #? because I can't find the path... for now, I will just leave the
                #? unresolved string there because it must have been for a reason?
                Write-Debug "  - $possibleLocation"
                $info[$location] = $possibleLocation
            }
        }
        #endregion Normalize paths
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Feature flags

        $flags = Get-FeatureFlag
        if ($null -ne $flags) {
            $info['Flags'] = $flags
        } else {
            Write-Debug "No feature flags were found"
        }

        #endregion Feature flags
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Version info
        $versionInfo = Get-ProjectVersionInfo

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
        #-------------------------------------------------------------------------------
        #region Configuration files

        foreach ($f in $ConfigurationFiles) {
            Write-Debug "Merging $f into BuildInfo"
            if (Test-Path $f) {
                $f | Merge-BuildConfiguration -Object ([ref]$info)
            }
        }

        #endregion Configuration files
        #-------------------------------------------------------------------------------
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
            Write-Debug "  - Adding field 'Paths' to module $($item.Name)"
            $item | Add-Member -NotePropertyName Paths -NotePropertyValue ($defaultLocations.Keys)
            foreach ($location in $defaultLocations.Keys) {
                $moduleLocation = (Join-Path $info[$location] $item.Name)
                Write-Debug "  - Adding $location Path : $moduleLocation"
                $item | Add-Member -NotePropertyName $location -NotePropertyValue $moduleLocation
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
        Write-Debug "Completed building configuration settings"
        $info
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
