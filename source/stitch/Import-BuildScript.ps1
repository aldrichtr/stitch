
<#
.SYNOPSIS
    Import the given build scripts into the current runspace
.DESCRIPTION
    This script will import the tasks defined in the module, the users ~/.stitch directory, and the current project.
    Before importing, the script will check the 'ExcludeTasksOnImport' list, which is a list of regex to block from
    being imported by this script
#>

param(
    [Parameter()]
    [string[]]$ExcludeScriptsOnImport = (
        Get-BuildProperty ExcludeScriptsOnImport @()
    ),

    [Parameter(
        DontShow
    )]
    [string]$InternalScriptPath  = "$PSScriptRoot\BuildScripts"
)

function Merge-BuildScript {
    <#
    .SYNOPSIS
        Add the scripts to the larger collection, replacing items based on BaseName
    #>
    param(
        [Parameter(
            Position = 1,
            ValueFromPipeline
        )]
        [ref]$Collection,

        [Parameter(
            Position = 0
        )]
        [Array]$Scripts
    )
    begin {
    }
    process {
        foreach ($currentScript in $Scripts) {
            <#
             if this script's file name exists in the Collection scripts array, we remove it from the
             and add this script,  otherwise just add the script
            #>
            $baseNames = $Collection.Value | Select-Object -ExpandProperty BaseName
            if ($baseNames -contains $currentScript.BaseName ) {
                $previousScript = $Collection.Value | Where-Object {
                    $_.BaseName -like $currentScript.BaseName
                }
                if ($null -ne $previousScript) {
                    Write-Verbose "Overriding $($currentScript.BaseName)"
                    $index = $Collection.Value.IndexOf( $previousScript )
                    $Collection.Value[$index] = $currentScript
                }
            } else {
                $Collection.Value += $currentScript
            }
        }
    }
    end {
    }
}

if ($null -eq $script:ImportErrors) {
    $script:ImportErrors = [ordered]@{}
}

# build scripts in the current project
$projectScripts = [System.Collections.ArrayList]@()

# build scripts in ~/.stitch
$systemScripts = [System.Collections.ArrayList]@()

# build scripts bundled with the stitch module
$moduleScripts = [System.Collections.ArrayList]@()

# Collated build scripts collection
$scriptFiles = [System.Collections.ArrayList]@()

<#------------------------------------------------------------------
  Start with the bundled scripts
------------------------------------------------------------------#>
Write-Debug "`n<$('-' * 80)"
Write-Debug "Collecting Invoke-Build build scripts:"

if ($null -ne $InternalScriptPath) {
    if (Test-Path $InternalScriptPath) {
        Write-Debug "  - Looking in the module's directory"
        $moduleScripts = $InternalScriptPath | Find-InvokeBuildScript
        if ($moduleScripts.Count -gt 0) {
            Write-Debug "    - Merging $($moduleScripts.Count) scripts"
            [ref]$scriptFiles | Merge-BuildScript $moduleScripts
        }
    }
} else {
    Write-Warning "Path to module task path is not set "
}
<#------------------------------------------------------------------
Layer on the system scripts
------------------------------------------------------------------#>
$systemPath = Find-LocalUserStitchDirectory
if ($null -ne $systemPath) {
    Write-Debug "  - Looking in the system path $systemPath"
    $systemScripts = $systemPath | Find-InvokeBuildScript
} else {
    Write-Debug "    - Did not find a local user stitch directory"
}

if ($systemScripts.Count -gt 0) {
    Write-Debug "    - Merging $($systemScripts.Count) scripts"
    [ref]$scriptFiles | Merge-BuildScript $systemScripts
}

<#------------------------------------------------------------------
Layer on the project scripts
------------------------------------------------------------------#>
#! hopefully, BuildConfigPath is set by .build.ps1
if ($null -ne $BuildConfigPath) {
    Write-Debug "Looking in $BuildConfigPath"
    $projectScripts = $BuildConfigPath | Find-InvokeBuildScript
} else {
    Write-Debug "BuildConfigPath is not set.  No build scripts loaded from project"
}


if ($projectScripts.Count -gt 0) {
    Write-Debug "    - Merging $($projectScripts.Count) scripts"
    [ref]$scriptFiles | Merge-BuildScript $projectScripts
}

Write-Debug "Merged all build scripts."
Write-Debug "`n$('-' * 80)>"

<#------------------------------------------------------------------
  Now, Process the merged collection
------------------------------------------------------------------#>

Write-Debug "`n<$('-' * 80)"
Write-Debug "Importing $($scriptFiles.Count) build scripts"

:file foreach ($file in $scriptFiles) {
    #-------------------------------------------------------------------------------
    #region Exclusions

    if (($null -ne $ExcludeScriptsOnImport) -and ($ExcludeScriptsOnImport.Count -gt 0)) {
        :exclude foreach ($exclude in $ExcludeScriptsOnImport) {
            # the filename matches at least one exclude, no need to keep checking
            if ($file.BaseName -match $exclude) {
                Write-Debug "$($file.BaseName) is excluded by pattern $exclude"
                #! do not import the script, go to the next file in the list
                continue file
            }
        }
    }

    #endregion Exclusions
    #-------------------------------------------------------------------------------

    try {
        Write-Debug "  - $($file.Name)"
        . $file.FullName
        } catch {
            <#
             This rather long catch block is collecting the relavant error information,
             and passing it up to the $ImportErrors script variable.
             ! this is because the files are imported in the .build.ps1 file, but we want
             ! to report the errors after the logs have been initialized and the rest of
             ! the components have a chance to load.

             ! The errors are reported in Enter-Build
            #>
            $importScriptName = Get-Item $PSCommandPath | Select-Object -ExpandProperty Name
            $message = [System.Text.StringBuilder]::new()

            $errorException = $_.Exception

            <#
            If there were parse errors in the imported script, then there will be an 'Errors' entry for each
            #>
            if ($errorException.Errors.Count -gt 0) {
                # Format the first line of our processed error message
                if ($errorException.Errors.Count -eq 1) {
                    $null = $message.Append("There was an error trying to import $($file.Name)")
                } else {
                        $null = $message.Append("There where $($errorException.Errors.Count) errors trying to import $($file.Name)")
                }
                $null = $message.AppendLine(": (")
                # Collect each of the parse errors and format them
                foreach ($importError in $errorException.Errors) {
                    $null = $message.AppendJoin(
                        '',
                        "  - ",
                        $importError.Extent.File,
                        ':',
                        $importError.Extent.StartLineNumber,
                        ':')
                    $null = $message.AppendLine( $importError.Extent.StartColumnNumber)
                    $null = $message.Append( '    - ')
                    $null = $message.AppendLine($importError.Message)
                }
            <#
            If there aren't any Errors entries, then process the error record.
            #>
            } elseif ($errorException.ErrorRecord.Count -gt 0) {
                if ($errorException.ErrorRecord.Count -eq 1) {
                    $null = $message.AppendLine("There was an error trying to import $($file.Name)")
                } else {
                    $null = $message.AppendLine("There where $($errorException.ErrorRecord.Count) errors trying to import $($file.Name)")
                }
                $null = $message.AppendLine(": (")
                foreach ($importError in $errorException.ErrorRecord) {
                    $null = $message.Append( '    - ')
                    $null = $message.AppendJoin(
                        '',
                        '  - ',
                        $importError.InvocationInfo.ScriptName,
                        ':',
                        $importError.InvocationInfo.ScriptLineNumber,
                        ':')
                    $null = $message.AppendLine( $importError.InvocationInfo.Offset.InLine)

                    $null = $message.AppendLine($importError.Exception.Message)
                    # Add the position message, unless it just points to this script
                    if (-not($importError.InvocationInfo.PositionMessage -match [regex]::Escape($importScriptName))) {
                        $null = $message.AppendLine($importError.InvocationInfo.PositionMessage)
                    }
                }
            } else {
                $null = $message.AppendLine("There was an error trying to import $($file.Name)")
                $null = $message.AppendLine($_)
            }
            Write-Debug "An error occured importing $($file.Name). $($message.ToString())"
            if ($null -ne $script:ImportErrors) {
                $script:ImportErrors.Add($file.Name,  $message.ToString())
            } else {
                Write-Debug "ImportErrors was not initialized"
                $message.ToString()
            }
        }
    }

    Write-Debug "`n$('-' * 80)>"
