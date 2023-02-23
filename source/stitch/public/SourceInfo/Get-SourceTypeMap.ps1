
function Get-SourceTypeMap {
    <#
    .SYNOPSIS
        Retrieve the table that maps source items to the appropriate Visibility and Type
    .LINK
        Get-SourceItemInfo
    #>
    [CmdletBinding()]
    param(
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if ($null -eq $script:SourceTypeMap) {
            Write-Debug   "Source type map not set.  Creating now."
            New-SourceTypeMap
        }
        $script:SourceTypeMap | Write-Output
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
