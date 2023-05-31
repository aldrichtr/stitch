
function Initialize-PhaseDefinition {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        [Parameter()]
        [string]$Filter = "*.psd1"
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            if ($null -ne $BuildConfigPath) {
                $Path = $BuildConfigPath
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if (Test-FeatureFlag 'phaseConfigFile') {
            if (Test-Path $Path) {
                Write-Debug "Loading phase configuration files from $Path with filter $Filter"
                $loadedPhases = @()

                $customPhaseFiles = Get-ChildItem @PSBoundParameters

                <#
                 load all of the user's phase definitions, if there are any that exist in the internal phases
                 directory load those afterward
                #>

                if ($customPhaseFiles.Count -gt 0) {
                    foreach ($phaseItem in $customPhaseFiles) {
                        #! Skip any Path that starts with a '.'
                        if ($phaseItem.BaseName -match '^\.') {
                            Write-Debug "  - Skipping $($phaseItem.Name)"
                            continue
                        }

                        Import-PhaseDefinition $phaseItem
                        Write-Debug "  - Imported phase configuration $($phaseItem.Name)"
                        $loadedPhases += $phaseItem.BaseName
                    }
                } else {
                    Write-Debug "No files found in $Path"
                }
            }

            if ($loadedPhases.Count -gt 0) {
                Write-Debug "  - $($loadedPhases.Count) phase configuration files loaded"
            }

        } else {
            Write-Debug "Feature flag 'phaseConfigFile' not enabled"
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
