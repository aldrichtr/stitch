
Set-Alias cleanse Add-CleanseTask
Set-Alias cleanup Add-CleanseTask

function Add-CleanseTask {
    <#
    .SYNOPSIS
        The `cleanse` task removes files and directories using the standard `Get-ChildItem` parameters.  Any paths
        listed in `$ExcludePathFromClean` will be Excluded
    .EXAMPLE
        cleanse 'clean.artifacts' -Path $Artifact -Filter '*' -Recurse
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [string]$Name,

        # The root path to clean
        [Parameter(
            Mandatory,
            Position = 1
        )]
        [string]$Path,

        # Wildcard pattern to include
        [Parameter(
            Position = 2
        )]
        [string[]]$Include,

        # Wildcard pattern to exclude
        [Parameter(
            Position = 3
        )]
        [string[]]$Exclude,

        # Filter pattern to include
        [Parameter(
            Position = 4
        )]
        [string]$Filter,

        # Include subfolders and items
        [Parameter(
        )]
        [switch]$Recurse,

        # Overwrite Destination if present
        [Parameter(
        )]
        [switch]$Force
    )

    Add-BuildTask $Name -Data $PSBoundParameters -Source $MyInvocation {
        <#------------------------------------------------------------------
          First, confirm that the path is within the project
        ------------------------------------------------------------------#>
        if (Test-Path $Task.Data.Path) {
            logDebug 'Checking path is in project prior to removing'
            try {
                $root = Resolve-ProjectRoot -ErrorAction Stop
            } catch {
                logError "Could not get the project root from $((Get-Location).Path)"
                return
            }
            if (-not($Task.Data.Path | Test-PathIsIn $root -CaseSensitive:($IsLinux -or $IsMacOS))) {
                logError "$($Task.Data.Path) is not in project ($root)"
                return
            }

            <#------------------------------------------------------------------
              Gather the items to be removed using the Parameters passed to
              Add-CleanseTask
            ------------------------------------------------------------------#>
            $options = $Task.Data
            $null = $options.Remove('Name')

            $items = Get-ChildItem @options

            logDebug "$($items.Count) items in $($options.Path) found for removal"
            if ($null -ne $items) {
            <#------------------------------------------------------------------
              Sort the items so that the contents of the folder are removed
              before the folder is removed
            ------------------------------------------------------------------#>
                 [array]::Reverse($items)
                 <#------------------------------------------------------------------
                 Remove the item if it is not found in $ExcludePathFromClean
                 ------------------------------------------------------------------#>
                 $excludeCount = 0
                :item foreach ($item in $items) {
                    if (-not([string]::IsNullorEmpty($ExcludePathFromClean))) {
                        #! the exclusions would be written as relative paths
                        $rel = [System.IO.Path]::GetRelativePath($root, $item.FullName)
                        logDebug "Checking for an exclusion for '$rel'"
                        foreach ($exclusion in $ExcludePathFromClean) {
                            $ex = [System.IO.Path]::GetRelativePath($root, $exclusion)
                            #! If we find a match skip to the next item
                            if ($rel -like $ex) {
                                logDebug "Excluded from Cleanse '$rel'"
                                $excludeCount++
                                continue item
                            }
                        }
                    } else {
                        logDebug "No exclusions found in project"
                    }
                        logDebug "  - Removing '$rel'"
                        if (Test-Path $item) {
                            $item | Remove-Item -Recurse
                        }
                }
                    logInfo "Cleansed $($options.Path) ($excludeCount items excluded)"
            } else {
                logDebug "No items found in Path $($options.Path)"
            }
        }
    }

}
