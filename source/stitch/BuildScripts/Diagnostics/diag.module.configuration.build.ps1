
#synopsis: Output Module configuration of the current project
task diag.module.configuration {

    $moduleNames = $BuildInfo.Modules.Keys
    function Format-ModuleInfo {
        param(
            [Object]$ModuleInfo
        )
        logInfo "Module $($moduleInfo.Name)"
        foreach ($prop in ($ModuleInfo.psobject.properties)) {
            switch ($prop.Name) {
                'SourceInfo' {
                    logInfo ('  - {0,-24} => {1} ' -f $prop.Name, "$($prop.Value.Count) Source Items")
                }
                'NestedModules' {
                    logInfo ('  - {0,-24} => {1} ' -f $prop.Name, "$($prop.Value.Count) Nested Modules")
                }
                'Parent' {
                    logInfo ('  - {0,-24} => {1} ' -f $prop.Name, "$($PSStyle.Foreground.BrightCyan)$($prop.Value -join ', ')$($PSStyle.Reset)")
                }
                default {
                    logInfo ('  - {0,-24} => {1} ' -f $prop.Name, ($prop.Value -join ', '))
                }
            }
        }
    }


    if ($moduleNames.Count -eq 0) {
        logWarning "No modules found in project"
    } elseif ($moduleNames.Count -eq 1) {
        $moduleName = $moduleNames[0]
        $config = $BuildInfo.Modules.Values | Where-Object Name -like $moduleName
        logInfo 'Single module project:'
        Format-ModuleInfo $config
    } else {
        logInfo "Multi module project:"
        $topLevelModules = $BuildInfo.Modules.Values | Where-Object Parent -EQ $null

        foreach ($top in $topLevelModules) {
            Format-ModuleInfo $top
            if ($top.NestedModules) {
                $moduleCount = 1
                foreach ($mod in $top.NestedModules) {
                    logInfo "$('-' * 60)"
                    logInfo "- Nested module $moduleCount of $($top.Name)"
                    $moduleCount++
                    if ($moduleNames -contains $mod.ModuleName) {
                        Format-ModuleInfo $BuildInfo.Modules[$mod.ModuleName]
                    } else {
                        logWarning "$($mod.ModuleName) was not found in project"
                    }
                }
            }
        }

    }
}
