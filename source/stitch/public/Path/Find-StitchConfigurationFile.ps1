
function Find-StitchConfigurationFile {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $possibleConfigFileFilters = @(
            'stitch.config.ps1',
            '.config.ps1'
        )
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        :path foreach ($location in $Path) {
            Write-Debug "Looking in $location"
            :filter foreach ($possibleConfigFileFilter in $possibleConfigFileFilters) {
                $options = @{
                    Path = $location
                    Recurse = $true
                    Filter = $possibleConfigFileFilter
                    File = $true
                }
                $result = Get-Childitem @options | Select-Object -First 1
                if ($null -ne $result) {
                    $result | Write-Output
                    continue path
                }
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
