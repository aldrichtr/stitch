
$options = @{
    Name = 'saveto'
    Value = 'Add-SaveToTask'
    Description = 'Save a module to the given Destination'
    Scope = 'Script'
}

Set-Alias @options
Remove-Variable options -ErrorAction SilentlyContinue

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
        # The name of the Invoke-Build Task
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


    task $Name -Data $PSBoundParameters -Source $MyInvocation {
        if (-not(Test-Path $Task.Data.Destination)) {
            throw "$($Task.Data.Destination) is not a valid path"
        } else {
            if ([string]::IsNullorEmpty($Task.Data.Module)) {
                if ([string]::IsNullorEmpty($BuildInfo)) {
                    $BuildInfo = Get-BuildConfiguration
                }
                $Task.Data.Module = $BuildInfo.Modules.Keys
            }
        }
        logInfo 'Copying Modules'
        $BuildInfo | Foreach-Module {
            $config = $_
            logInfo "- Module: $($config.Name)"
            if ($Task.Data.Module -contains $config.Name) {
                $options = @{
                    Path        = $config.Staging
                    Destination = $Task.Data.Destination
                    Recurse     = $true
                    Force       = $Task.Data.Force

                }
                try {
                    logDebug "Save module $($config.Name) : $($options.Path) to $($options.Destination)"
                    Copy-Item @options
                } catch {
                    throw "Could not save module $($config.Name) to $($options.Destination)`n$_"
                }
            } else {
                logInfo "$($config.Name) was not included in $($Task.Name) Module parameter"
            }
        }
    }
}
