
function Find-BuildRunBook {
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
        $possibleRunbookFilters = @(
            "*runbook.ps1"
        )
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        :path foreach ($location in $Path) {
            :filter foreach ($possibleRunbookFilter in $possibleRunbookFilters) {
                $options = @{
                    Path = $location
                    Recurse = $true
                    Filter = $possibleRunbookFilter
                    File = $true
                }
                Get-Childitem @options
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
