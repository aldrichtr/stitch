
Set-Alias saveto Add-SaveToTask

function Add-SaveToTask {
    <#
    .SYNOPSIS
        Save the module directory from staging to the Destination
    .DESCRIPTION
        Add-SaveToTask mirrors the `Save-Module` functionality.
    .EXAMPLE
        Add-SaveToTask -Destination $env:HOME\CustomModules
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [string]$Name,

        # The target directory to save the module to
        [Parameter(
            Position = 1
        )]
        [string]$Destination,

        # The name of the module[s] to save.  All modules in the project are saved by default
        [Parameter(
            Position = 2
        )]
        [string[]]$Module,

        # Overwrite Destination if present
        [Parameter(
        )]
        [switch]$Force
    )

    if (-not(Test-Path $Destination)) {
        throw "$Destination is not a valid path"
    } else {
        if (-not($PSBoundParameters.ContainsKey('Module'))) {
            if ([string]::IsNullorEmpty($BuildInfo)) {
                $BuildInfo = Get-BuildConfiguration
            }
            $PSBoundParameters['Module'] = $BuildInfo.Modules.Keys
        }
    }

    task $Name -Data $PSBoundParameters -Source $MyInvocation {
        logInfo 'Copying Modules'
        foreach ($key in $BuildInfo.Modules.Keys) {
            logInfo "Module: $key"
            if ($Task.Data.Module -contains $key) {
                $config = $BuildInfo.Modules[$key]
                $options = @{
                    Path        = $config.Staging
                    Destination = $Task.Data.Destination
                    Recurse     = $true
                    Force       = $Task.Data.Force

                }
                try {
                    logDebug "Save module $key : $($options.Path) to $($options.Destination)"
                    Copy-Item @options
                } catch {
                    throw "Could not save module $key to $($options.Destination)`n$_"
                }
            }
        }
    }
}
