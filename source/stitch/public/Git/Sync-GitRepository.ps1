
function Sync-GitRepository {
    <#
    .SYNOPSIS
        Update the working directory of the current branch
    .DESCRIPTION
        This is equivelant to `git pull --rebase
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Medium'
    )]
    param()
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        $br = Get-GitBranch -Current
        if ($br.IsTracking) {
            $remote = $br.TrackedBranch
            if ($PSCmdlet.ShouldProcess($br.FriendlyName, "Update")) {
                $br | Send-GitBranch origin
                Start-GitRebase -Upstream $remote.FriendlyName -Branch $br.FriendlyName
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
