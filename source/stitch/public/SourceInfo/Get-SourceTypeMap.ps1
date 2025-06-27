
function Get-SourceTypeMap {
    <#
    .SYNOPSIS
        Retrieve the table that maps source items to the appropriate Visibility and Type
    .LINK
        Get-SourceItemInfo
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to the source type map file.
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        #TODO: Another item that would be good to add to the PoshCode Configuration
        New-Variable -Name DEFAULT_FILE_NAME -Value 'sourcetypes.config.psd1' -Option Constant
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('Path'))) {
            Write-Debug "No Path given.  Looking for Map file in Build Configuration Directory"
            $possibleBuildConfigPath = Find-BuildConfigurationDirectory

            if ($null -ne $possibleBuildConfigPath) {
                $possibleMapFile = (Join-Path $possibleBuildConfigPath $DEFAULT_FILE_NAME)
            }

            if ($null -eq $possibleMapFile) {
                Write-Debug "Not found.  Looking for Map file in Build Configuration Root Directory"
                $possibleBuildConfigPath = Find-BuildConfigurationRootDirectory

                if ($null -ne $possibleBuildConfigPath) {
                    $possibleMapFile = (Join-Path $possibleBuildConfigPath $DEFAULT_FILE_NAME)
                }
            }
        } else {
            if (Test-Path $Path) {
                $pathItem = Get-Item $Path
                if ($pathItem.PSIsContainer) {
                    $possibleMapFile = (Join-Path $Path $DEFAULT_FILE_NAME)
                } else {
                    $possibleMapFile = $Path
                }
            }
        }

        if (Test-Path $possibleMapFile) {
            Write-Verbose "Source Type Map file was found at $possibleMapFile"
            try {
                $config = Import-Psd $possibleMapFile -Unsafe
                if ($null -ne $config) {
                    $config['TypeMapFilePath'] = $possibleMapFile
                    $config | Write-Output
                }
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        } else {
            Write-Error "No $DEFAULT_FILE_NAME could be found"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
