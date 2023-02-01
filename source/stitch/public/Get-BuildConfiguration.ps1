
function Get-BuildConfiguration {
    [CmdletBinding()]
    param(
        # Path to the build configuration file
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # Default Configuration file
        [Parameter(
        )]
        [string]$Defaults = "$($MyInvocation.MyCommand.Module.ModuleBase)\Defaults.psd1"
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $config_dir_default = (Join-Path (Get-Location) '.\build\config')

        $failsafe_defaults = @{
            Source   = '.\source'
            Tests    = '.\tests'
            Staging  = '.\stage'
            Artifact = '.\out'
            Docs     = '.\docs'
        }
        $info = [ordered]@{}


        # Ensure we have some sane defaults
        if (Test-Path $Defaults) {
            Write-Verbose "  Loading defaults from $Defaults"
            $info = (Import-Psd $Defaults)
        } else {
            $null = $info | Update-Object $failsafe_defaults
        }

        # Set the Name here early, it may be overwritten by a config file later
        try {

            Write-Debug "Resolving project root"
            $root = (Get-Item (Resolve-ProjectRoot -ErrorAction SilentlyContinue))

        } catch {
            Write-Warning "Could not find Project Root"
        }

        if ($null -ne $root) {
            Write-Debug " - root found.`nPath is : $($root.FullName)`nName is $($root.BaseName)"
            $info['Project'] = @{
                Path = $root.FullName
                Name = $root.BaseName
            }
        } else {
            Write-Debug " - Project root was not found"
            $info['Project'] = @{
                Path = ''
                Name = ''
            }

        }

        $gitver_cmd = Get-Command dotnet-gitversion.exe
        if ($null -eq $gitver_cmd) {
            throw "GitVersion is not installed.`nsee <https://gitversion.net/docs/usage/cli/installation> for details "
        } else {
            $version_info = & $gitver_cmd @('/nofetch', '/output', 'json')
            if ($null -ne $version_info) {
                $info.Project['Version'] = ($version_info | ConvertFrom-Json)
            }
        }
    }
    process {
        if ($PSBoundParameters.Keys -notcontains 'Path') {
            if (Test-Path $config_dir_default) {
                $Path = (Get-ChildItem (Join-Path (Get-Location) '.build\config') -Filter '*.config.psd1') |
                    Select-Object -ExpandProperty FullName
            }
        }
        try {
            foreach ($p in $Path) {
                Write-Verbose "  Loading $p into configuration"
                if ($info.Keys.Count -eq 0) {
                    $info = Import-Psd $p
                } else {
                    $null = $info | Update-Object (Import-Psd $p)
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
                $mod = $info.Modules[$key]
                if ($null -ne $mod.NestedModules) {
                    foreach ($nest in $mod.NestedModules) {
                        if ($nest -is [string]) {
                            $n_name = $nest
                        } elseif ($nest -is [hashtable]) {
                            $n_name = $nest.ModuleName
                        }
                        Write-Debug "  Nested module: $n_name"
                        $found = ''
                        switch -Regex ($n_name) {
                            '[\\/]?(?<fname>)\.psm1$' {
                                Write-Debug "  - Found path to module file $($Matches.fname)"
                                $found = $Matches.fname
                                continue
                            }
                            '(\w+[\\/])*(?<lword>\w+)$' {
                                Write-Debug "  - Found path to directory $($Matches.lword)"
                                $found = $Matches.lword
                                continue
                            }
                            Default {
                                Write-Debug '  - Does not match a pattern'
                                $found = $n_name
                            }
                        }
                        if ($info.Modules.Keys -contains $found) {
                            Write-Debug "  Adding $($mod.Name) as parent of $found"
                            $info.Modules[$found] | Add-Member -NotePropertyName 'Parent' -NotePropertyValue $mod.Name
                        }
                    }
                }
            }

        } catch {
            Write-Information "Could not use configuration file $p.`n$_"
        }
    }
    end {
        $info
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
