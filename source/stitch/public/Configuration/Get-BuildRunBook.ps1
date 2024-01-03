
function Get-BuildRunBook {
    <#
    .SYNOPSIS
        Return the runbooks in the given directory
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
        [string[]]$Path,

        # Optionally recurse into children
        [Parameter(
        )]
        [switch]$Recurse,

        # Optional runbook filter
        [Parameter(
        )]
        [string]$Filter = '*runbook.ps1'
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

    }
    process {
        Write-Debug "Looking for runbooks in $($Path.FullName)'"
        $options = @{
            Path = $Path
            Recurse = $Recurse
            Filter = $Filter
        }
        Get-ChildItem @options
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
