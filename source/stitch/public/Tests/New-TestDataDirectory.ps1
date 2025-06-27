
function New-TestDataDirectory {
    <#
    .SYNOPSIS
        Create a standard directory for test data
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
        [string]$Path,

        # Return the new data directory
        [Parameter(
        )]
        [switch]$PassThru
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $directory = $Path | Split-Path
        $newName = $Path | Split-Path -LeafBase
        $newName = $newName -replace 'Tests$', 'Data'

        $dataDirectory = (Join-Path $directory $newName)
        if (-not($dataDirectory | Test-Path)) {
            $dir = mkdir $dataDirectory -Force
            if ($PassThru) {
                $dir
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
