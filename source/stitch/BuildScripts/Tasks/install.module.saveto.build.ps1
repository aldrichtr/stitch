
param(
    # Location to save the modules to (copy from staging)
    [Parameter()]
    [string]$InstallSaveToPath = (
        Get-BuildProperty InstallSaveToPath (Resolve-Path ($env:PSModulePath -split ';' | Select-Object -First 1))
    ),

    # List of modules to save (all modules in project by default)
    [Parameter()]
    [string[]]$InstallSaveToModules = (
        Get-BuildProperty InstallSaveToModules ($BuildInfo.Modules.Keys)
    )
)

<#
.SYNOPSIS
Copy the module(s) from the staging directory to -InstallSaveToPath
#>
#Parameters: InstallSaveToPath, InstallSaveToModules
saveto install.module.saveto -Destination $InstallSaveToPath -Module $InstallSaveToModules -Force
