
<#
.SYNOPSIS
    If any modules are listed as nested in the manifest, move the staged module under the parent
#>
task move.nested.module {
     $BuildInfo | Foreach-Module {
        $config = $_
        $name = $config.Name
        if (-not([string]::IsNullorEmpty($config.Parent))) {
            logInfo "$name is a nested module of $($config.Parent)"
            if ($BuildInfo.Modules.Containskey($config.Parent)) {
                logDebug "  $($config.Parent) is part of this project"
                $parent = $buildInfo.Modules[$config.Parent]
                $destination = $parent.Staging
                logDebug "  moving staged $name module to $destination"
                $options = @{
                    Path = $config.Staging
                    Destination = $parent.Staging
                }
                try {
                    Move-Item @options
                    if (Test-Path (Join-Path $parent.Staging $name)) {
                        logInfo "$name moved to $($parent.Staging)"
                    }
                }
                catch {
                    throw "Could not move $name to Parent module location $($parent.Staging)`n$_"
                }
            } else {
                logError "$name  is listed as a nested module of $($config.Parent), but $($config.Parent) was not found in project "
            }
        }
    }
}
