
param(
    [Parameter()]
    [string]$CustomPhasePath = (
        Get-BuildProperty CustomPhasePath (Join-Path $BuildConfigPath 'phases')
    ),

    [Parameter()]
    [string]$CustomPhaseFilter = (
        Get-BuildProperty CustomPhaseFilter '*.*'
    ),

    [Parameter(
        DontShow
    )]
    [string]$InternalPhasePath = (Join-Path $PSScriptRoot 'phases')
)

$phaseAlias = Get-Alias 'phase' -ErrorAction SilentlyContinue

if ($null -eq $phaseAlias) {
    Set-Alias -Name phase -Value Add-BuildTask -Description 'Top level task associated with a development lifecycle phase'
}

Remove-Variable phaseAlias
#-------------------------------------------------------------------------------
#region phase definition

#synopsis: Reset the environment and remove any generated files, directories, or settings
phase Clean

#synopsis: configure the project is correct and all necessary information is available
phase Validate

#synopsis:	initialize build state, e.g. set properties or create directories.
phase Initialize

#synopsis: In projects with compiled language source, run the compiler to produce an executable
phase Compile

#synopsis: Build the source code (create/assemble a module, manifest and supporting files from source)
phase Build

#synopsis: Run unit tests against the source module
phase Test

#synopsis: Create a distributable package from the project
phase Package

#synopsis: Run any checks on results of integration tests to ensure quality criteria are met
phase Verify

#synopsis: Copy the final package to the remote repository
phase Deploy

#synopsis: Install the modules from the system local PSRepo
phase Install

#synopsis: Remove and uninstall the module from the system
phase Uninstall

#endregion phase definition
#-------------------------------------------------------------------------------

if (Test-FeatureFlag 'phaseConfigFile') {

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
            Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

            if (Test-Path $Path) {

                $phaseName = $Path.BaseName

                switch -Regex ($Path.Extension) {
                    '\.psd1' {
                        #! Note we use the 'Unsafe' parameter so we can have scriptblocks and
                        #! variables in our psd
                        $phaseOptions = (Import-Psd -Path $Path -Unsafe)
                    }
                    '\.y(a)?ml' {
                        $phaseOptions = (Get-Content $Path | ConvertFrom-Yaml -Ordered)
                    }
                    '\.json(c)?' {
                        $phaseOptions = (Get-Content $Path | ConvertFrom-Json)
                    }
                    default {
                        logError "Could not determine the type for $($Path.FullName)"
                    }
                }
                if ($null -ne $phaseOptions) {
                    $phaseOptions['Name'] = $phaseName

                    if (${*}.All.Keys -contains $phaseName) {
                        $null = ${*}.All[$phaseName] | Update-Object -UpdateObject $phaseOptions
                    } else {
                        phase @phaseOptions
                    }
                }
            }
            Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        }
        end {
            Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        }
    }



    if (Test-Path $CustomPhasePath) {
        Write-Debug 'Loading phase configuration files'
        $loadedPhases = @()

        $customPhaseFiles = Get-ChildItem -Path $CustomPhasePath -Filter $CustomPhaseFilter

        <#
    load all of the user's phase definitions, if there are any that exist in the internal phases
    directory load those afterward
    #>

        foreach ($Path in $customPhaseFiles) {
            #! Skip any Path that starts with a '.'
            if ($Path.BaseName -match '^\.') {
                Write-Debug "  - Skipping $($Path.Name)"
                continue
            }

            Import-PhaseDefinition $Path
            Write-Debug "  - Imported phase configuration $($Path.Name)"
            $loadedPhases += $Path.BaseName
        }
    }


    if (Test-Path $internalPhasePath) {
        $internalPhaseFiles = Get-ChildItem -Path $InternalPhasePath -Filter '*.psd1'
        foreach ($Path in $internalPhaseFiles) {
            #! Skip any Path that starts with a '.'
            if ($Path.BaseName -match '^\.') {
                Write-Debug "  - Skipping $($Path.Name)"
                continue
            }

            if ($loadedPhases -contains $Path.BaseName) {
                Write-Debug "  - $($Path.BaseName) already loaded"
                continue
            } else {
                Import-PhaseDefinition $Path
                Write-Debug "  - Imported phase configuration $($Path.Name)"
                $loadedPhases += $Path.BaseName
            }
        }
    }

    if ($loadedPhases.Count -gt 0) {
        Write-Debug "  - $($loadedPhases.Count) phase configuration files loaded"
    }

    Remove-Variable loadedPhases
}
