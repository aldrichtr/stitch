param(
    [Parameter()][hashtable]$CopyAdditionalItems = (
        Get-BuildProperty CopyAdditionalItems @{}
    ),

    [Parameter()][switch]$CopyEmptySourceDirs = (
        Get-BuildProperty CopyEmptySourceDirs $false
    )
)


#synopsis: Copy items from Source to Staging listed in the module's key in $CopyAdditionalItems
task copy.additional.item {
    if ($null -ne $CopyAdditionalItems) {
        if ($CopyAdditionalItems.Keys.Count -gt 0) {
             $BuildInfo | Foreach-Module {
                $name = $_.Name
                logDebug "Looking for additional source items for $name"
                if ($CopyAdditionalItems.ContainsKey($name)) {
                    $config = $_
                    :item foreach ($item in $CopyAdditionalItems[$name].GetEnumerator()) {
                        if ($item.Value -is [string]) {
                            $destination = (Join-Path $config.Staging $item.Value)
                        }
                        elseif ($item.Value -is [bool]) {
                            if ($item.Value) {
                                $destination = (Join-Path $config.Staging $item.Name)
                            } else {
                                logInfo ("$($item.Name) is false. Skipping")
                                continue item
                            }
                        }
                        $options = @{
                            Path        = (Join-Path $config.Source $item.Name)
                            Destination = $destination
                            #TODO: Should we always set Recurse and Force ?
                            Recurse     = $true
                            Force       = $true
                        }
                        if (-not(Test-Path $options.Path)) {
                            logWarn "CopyAdditionalItems.$name $($item.Name) = $($item.Value) is not a valid path"
                            continue item
                        }
                        try {
                            $isFolder = $false
                            if ((Get-Item $options.Path).PSIsContainer) {
                                $found = (Get-ChildItem $options.Path)
                                if ($found.Count -eq 0) {
                                    $isFolder = $true
                                    if ($CopyEmptySourceDirs) {
                                        logInfo "$($item.Name) is empty but 'CopyEmptySourceDirs' is set"
                                    } else {
                                        logInfo "$($item.Name) is empty set 'CopyEmptySourceDirs' to include this directory"
                                        continue item
                                    }
                                }
                            }
                            logInfo "Copying $(Resolve-Path $options.Path -Relative) to $($options.Destination). $( ($options.Recurse) ? 'Recursively' : 'Non-Recursive' ) "
                            Copy-Item @options
                        } catch {
                            $message = ( -join @(
                                    'Could not copy additional item ',
                                    "CopyAdditionalItems.$name ",
                                    $item.Name, ' = ', $item.Value,
                                    "`n$_"))
                            throw (logError $message -Passthru)
                        }
                    }
                } else {
                    logDebug "No additional items to copy for $name"
                }
            }
        } else {
            logDebug "CopyAdditionalItems is empty"
        }

    } else {
        logDebug "CopyAdditionalItems is not set"
    }
}
