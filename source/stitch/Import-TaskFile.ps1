
<#
.SYNOPSIS
    Import the given task files into the current runspace
.DESCRIPTION
    This script will import the functions defined in the module, the users ~/.stitch directory, and the current
    project.  Before importing, the script will check the 'ExcludeTasksOnImport' list, which is a list of regex to
    block from being imported by this script
#>

param(
    [Parameter()]
    [string[]]$ExcludeTasksOnImport = (
        Get-BuildProperty ExcludeTasksOnImport @()
    ),

    [Parameter(
        DontShow
    )]
    [string]$InternalTaskPath = "$PSScriptRoot\BuildScripts"
)

function Merge-TaskFile {
    <#
    .SYNOPSIS
        Add the task definition to the larger collection, replacing items based on BaseName
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
        [Array]$TaskFiles
    )
    begin {
    }
    process {
        foreach ($currentTaskFile in $TaskFiles) {
            <#
             if this script's file name exists in the Collection scripts array, we remove it from the
             and add this script,  otherwise just add the script
            #>
            $baseNames = $Collection.Value | Select-Object -ExpandProperty BaseName
            if ($baseNames -contains $currentTaskFile.BaseName ) {
                $previousTaskFile = $Collection.Value | Where-Object {
                    $_.BaseName -like $currentTaskFile.BaseName
                }
                if ($null -ne $previousTaskFile) {
                    Write-Verbose "Overriding $($currentTaskFile.BaseName)"
                    $index = $Collection.Value.IndexOf( $previousTaskFile )
                    $Collection.Value[$index] = $currentTaskFile
                }
            } else {
                $Collection.Value += $currentTaskFile
            }
        }
    }
    end {
    }
}


if ($null -eq $script:ImportErrors) {
    $script:ImportErrors = [ordered]@{}
}

# Task files in the current project
$projectTaskFiles = [System.Collections.ArrayList]@()

# Task files in ~/.stitch
$systemTaskFiles = [System.Collections.ArrayList]@()

# Task files bundled with the stitch module
$moduleTaskFiles = [System.Collections.ArrayList]@()

# Collated Task files collection
$taskFiles = [System.Collections.ArrayList]@()

<#------------------------------------------------------------------
  Start with the bundled task files
------------------------------------------------------------------#>
Write-Debug "`n<$('-' * 80)"
Write-Debug 'Collecting Invoke-Build task files:'
if ($null -ne $InternalTaskPath) {
    if (Test-Path $InternalTaskPath) {
        Write-Debug "  - Looking in the module's directory"
        $moduleTaskFiles = $InternalTaskPath | Find-InvokeBuildTaskFile
        if ($moduleTaskFiles.Count -gt 0) {
            Write-Debug "    - Merging $($moduleTaskFiles.Count) task files"
            [ref]$taskFiles | Merge-TaskFile $moduleTaskFiles
        }
    }
} else {
    Write-Warning "Path to module task path is not set "
}
<#------------------------------------------------------------------
Layer on the system task files
------------------------------------------------------------------#>
Write-Debug "Looking for a stitch directory in user's home directory"
$systemPath = Find-LocalUserStitchDirectory
if ($null -ne $systemPath) {
    Write-Debug "  - Looking in the system path $systemPath"
    $systemTaskFiles = $systemPath | Find-InvokeBuildTaskFile
} else {
    Write-Debug '    - Did not find a local user stitch directory'
}

if ($systemTaskFiles.Count -gt 0) {
    Write-Debug "    - Merging $($systemTaskFiles.Count) task files"
    [ref]$taskFiles | Merge-TaskFile $systemTaskFiles

}

<#------------------------------------------------------------------
Layer on the project task files
------------------------------------------------------------------#>
#! hopefully, BuildConfigPath is set by .build.ps1
if ($null -ne $BuildConfigPath) {
    Write-Debug "  - Looking in $BuildConfigPath"
    $projectTaskFiles = $BuildConfigPath | Find-InvokeBuildTaskFile
} else {
    Write-Debug 'BuildConfigPath is not set.  No task files loaded from project'
}


if ($projectTaskFiles.Count -gt 0) {
    Write-Debug "    - Merging $($projectTaskFiles.Count) task files"
    [ref]$taskFiles | Merge-TaskFile $projectTaskFiles
}

Write-Debug "Merged all task files."
Write-Debug "`n$('-' * 80)>"

<#------------------------------------------------------------------
  Now, Process the merged collection
------------------------------------------------------------------#>

Write-Debug "`n<$('-' * 80)"
Write-Debug "Importing $($taskFiles.Count) task files"

:file foreach ($file in $taskFiles) {
    #-------------------------------------------------------------------------------
    #region Exclusions

    if (($null -ne $ExcludeTasksOnImport) -and ($ExcludeTasksOnImport.Count -gt 0)) {
        :exclude foreach ($exclude in $ExcludeTasksOnImport) {
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
        Write-Debug "  -  $($file.Name)"
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
            $null = $message.AppendLine(': (')
            # Collect each of the parse errors and format them
            foreach ($importError in $errorException.Errors) {
                $null = $message.AppendJoin(
                    '',
                    '  - ',
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
            $null = $message.AppendLine(': (')
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
        Write-Debug "An error occured importing $($file.Name):`n$($message.ToString())"
        if ($null -ne $script:ImportErrors) {
            $script:ImportErrors.Add($file.Name, $message.ToString())
        } else {
            Write-Debug 'ImportErrors was not initialized'
            $message.ToString()
        }
    }
}

Write-Debug "`n$('-' * 80)>"
