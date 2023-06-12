function Get-GitMergedBranch {
    <#
    .SYNOPSIS
        Return a list of branches that have been merged into the given branch (or default branch if none specified)
    #>
    [CmdletBinding()]
    param(
        # The branch to use for the "base" (the branch the returned branches are merged into)
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$FriendlyName = (Get-GitHubDefaultBranch)
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        $defaultTip = Get-GitBranch -Name $FriendlyName |
            Foreach-Object {$_.Tip.Sha }

        Get-GitBranch | Where-Object {
            ($_.FriendlyName -ne $FriendlyName) -and ($_.Commits |
                    Select-Object -ExpandProperty Sha) -contains $defaultTip
            } | Write-Output

        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
