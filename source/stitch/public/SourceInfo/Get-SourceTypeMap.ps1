
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
        $moduleMapName = 'script:_stitchSourceTypeMap'
    }
    process {
        <#
         ! If we already loaded the map, then return that one
         TODO: I need a better way to manage the items that depend on the variables set during Invoke-Build when not in Invoke-Build
         #>
        $map = (Get-Variable -Name $moduleMapName -ValueOnly -ErrorAction SilentlyContinue)
        if ($null -ne $map) {
            Write-Debug "found map in $moduleMapName"
            $map | Write-Output
        } else {
            Write-Debug   "Source type map not set.  Creating now."
            if ($PSBoundParameters.ContainsKey('Path')) {
                New-SourceTypeMap -PassThru -Path $Path | Write-Output
            } else {
                New-SourceTypeMap -PassThru | Write-Output
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
