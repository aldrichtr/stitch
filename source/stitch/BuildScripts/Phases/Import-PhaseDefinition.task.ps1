
function Import-PhaseDefinition {
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
        if (Test-InInvokeBuild) {
            Write-Debug "Getting ready to Import phase definition file $Path"
            if (Test-Path $Path) {
                Write-Debug '  - File exists'
                $phaseItem = Get-Item $Path
                $phaseName = $phaseItem.BaseName
                Write-Debug "  - Setting phase name to $phaseName"
                switch -Regex ($phaseItem.Extension) {
                    '\.psd1' {
                        #! Note we use the 'Unsafe' parameter so we can have scriptblocks and
                        #! variables in our psd
                        Write-Debug '  - Importing PSD'
                        $phaseOptions = (Import-Psd -Path $phaseItem -Unsafe)
                    }
                    '\.y(a)?ml' {
                        Write-Debug '  - Importing YAML'
                        $phaseOptions = (Get-Content $phaseItem | ConvertFrom-Yaml -Ordered)
                    }
                    '\.json(c)?' {
                        Write-Debug '  - Importing JSON'
                        $phaseOptions = (Get-Content $phaseItem | ConvertFrom-Json)
                    }
                    default {
                        Write-Debug "Could not determine the type for $($phaseItem.FullName)"
                    }
                }
                if ($null -ne $phaseOptions) {
                    Write-Debug 'Loaded phase options from file'

                    if (${*}.All.Keys -contains $phaseName) {
                        Write-Debug "  - '$phaseName' phase found in list of all tasks"
                        Write-Debug "    - Updating object with options $($phaseOptions.Keys -join ', ')"
                        Write-Debug "      - Job count before: $(${*}.All[$phaseName].Jobs.Count)"
                        Write-Verbose "Updating $phaseName from $($phaseItem.Name)"
                        try {
                            $null = ${*}.All[$phaseName] | Update-Object -UpdateObject $phaseOptions
                        } catch {
                            throw "There was an error updating phase $phaseName`n$_"
                        }
                        Write-Debug "      - Job count after: $(${*}.All[$phaseName].Jobs.Count)"
                    } else {
                        Write-Debug "  - $phaseName NOT found in list of all tasks"
                        Write-Debug "    - Creating object with options $($phaseOptions.Keys -join ', ')"
                        Write-Verbose "Creating $phaseName from $($phaseItem.Name)"
                        phase @phaseOptions
                    }
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
