function Get-GitModifiedFile {
    <#
    .SYNOPSIS
        Return a list of the files modified in the current repository
    #>
    [CmdletBinding()]
    param()
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Get-GitFile -Type Modified
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
