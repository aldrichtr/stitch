
function Get-ChangelogConfig {
    <#
    .SYNOPSIS
        Look for a psd1 configuration file in the local folder, the path specified, or the module folder
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path
    )
    begin {
        $defaultConfigFile = '.changelog.config.psd1'
    }
    process {
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            #! if not specified, look in the local directory for the config file
            $Path = Get-Location
        }

        Write-Debug "Path is set as $Path"
        if (Test-Path $Path) {
            $pathItem = Get-Item $Path
            if ($pathItem.PSIsContainer) {
                Write-Debug "Path is a directory.  Looking for $defaultConfigFile"
                $possiblePath = (Join-Path $pathItem $defaultConfigFile)
                # look for the file in the directory
                if (Test-Path $possiblePath) {
                    Write-Debug "  - Found"
                    $configFile = Get-Item $possiblePath
                }
            } else {
                $configFile = $pathItem
            }

        } else {
            $configFile = Get-Item (Join-Path $ExecutionContext.SessionState.Module.ModuleBase $defaultConfigFile)
        }
        Write-Verbose "Loading configuration from $($configFile.FullName)"
        $config = Import-PowerShellDataFile $configFile.FullName

    }
    end {
        $config
    }
}
