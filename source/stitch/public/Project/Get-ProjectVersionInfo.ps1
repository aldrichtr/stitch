function Get-ProjectVersionInfo {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            $Path = Get-Location
        }
        #TODO: We could also parse the version field from the root module's manifest
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
                Write-Verbose "Using $found for version info"
                Write-Debug "    - Found $($found.FullName)"
                switch -Regex ($found.extension) {
                    'psd1' { $versionInfo = Import-Psd $found }
                    'json' { $versionInfo = (Get-Content $found | ConvertFrom-Json) }
                    'y(a)?ml' { $versionInfo = (Get-Content $found | ConvertFrom-Yaml) }
                    Default { Write-Information "$($found.Name) found but no converter for $($found.extension) is set" }
                }
            } else {
                Write-Debug "    - No version files found in $Path"
                $buildInfo = $PSCmdlet.GetVariableValue('BuildInfo')

                if ($null -ne $buildInfo) {
                    switch ($buildInfo.Modules.Keys.Count) {
                        0 {
                            throw "Could not find any modules in project to get version info"
                        }
                        1 {
                            $buildInfo.Modules[0].ModuleVersion | Write-Output
                        }
                        default {
                            Write-Verbose "Multiple module versions found using highest version"
                            $buildInfo.Modules.ModuleVersion | Sort-Object -Descending |
                                Select-Object -First 1 | Write-Output
                        }
                    }
                }
            }

        } else {
            Write-Verbose "Using gitversion for version info"
            $gitVersionCommandInfo = & $gitverCmd @('-?')

            Write-Debug '  - gitversion found.  Getting version info'
            $gitVersionCommandInfo | Write-Debug
            $gitVersionOutput = & $gitverCmd @( '-output', 'json')
            if ([string]::IsNullorEmpty($gitVersionOutput)) {
                Write-Warning "No output from gitversion"
            } else {
                Write-Debug "Version info: $gitVersionOutput"
                try {
                    $versionInfo = $gitVersionOutput | ConvertFrom-Json
                } catch {
                    throw "Could not parse json:`n$gitVersionOutput`n$_"
                }
            }
        }
    }
    end {
        $versionInfo
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
