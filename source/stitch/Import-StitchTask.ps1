
param(
    [Parameter()]
    [string[]]$ExcludeTasksOnImport = (
        property ExcludeTasksOnImport @()
    ),

    [Parameter(
        DontShow
    )]
    [string]$TaskPath  = "$PSScriptRoot\BuildScripts"
)

<#
.SYNOPSIS
    Import the given build scripts into the current runspace
.DESCRIPTION
    This script will import the tasks defined in the local $taskFiles list
    Before importing, the script will check the 'ExcludeTasksOnImport' list, which is a list of
    regex to block from being imported by this script
#>

$taskFiles = @()
if (Test-Path $TaskPath) {
    Get-ChildItem $taskPath -Filter '*.task.ps1' -Recurse | ForEach-Object { $taskFiles += $_ }
    Get-ChildItem $taskPath -Filter '*.build.ps1' -Recurse | ForEach-Object { $taskFiles += $_ }

    Write-Debug "Found $($taskFiles.Count) files in $taskPath"

:file foreach ($file in $taskFiles) {
    if (($null -ne $ExcludeTasksOnImport) -and ($ExcludeTasksOnImport.Count -gt 0)) {
        :exclude foreach ($exclude in $ExcludeTasksOnImport) {
            # the filename matches at least one exclude, no need to keep checking
            if ($file.BaseName -match $exclude) {
                Write-Debug "$($file.BaseName) is excluded by pattern $exclude"
                continue file
            }
        }
    }
    Write-Debug "Importing task from $($file.Name)"
    try {
        . $file.FullName
    } catch {

        throw (-join @(
            "There was an error trying to import $($file.Name)",
            ":$($PSItem.Exception.Line)",
            ":$($PSItem.Exception.Offset)",
            "`n",
            $PSItem.ToString()
            ))
        }
    }
} else {
    Write-Warning "$TaskPath is not a valid path"
}
