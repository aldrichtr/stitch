
function Clear-MergedGitBranch {
    <#
    .SYNOPSIS
        Prune remote branches and local branches with no tracking branch
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    param(
        # Only clear remote branches
        [Parameter(
            ParameterSetName = 'Remote'
        )]
        [switch]$RemoteOnly,
        # Only clear remote branches
        [Parameter(
            ParameterSetName = 'Local'
        )]
        [switch]$LocalOnly
    )
    Write-Verbose "Pruning remote first"
    if (-not ($LocalOnly)) {
        if ($PSCmdlet.ShouldProcess("Remote origin", "Prune")) {
            #TODO: Find a "PowerGit way" to do this part
            git remote prune origin
        }
    }
    if (-not ($RemoteOnly)) {
        $branches = Get-GitBranch | Where-Object { $_.IsTracking -and $_.TrackedBranch.IsGone }
        if ($null -ne $branches) {
            Write-Verbose "Removing $($branches.Count) local branches"
            foreach ($branch in $branches) {
                if ($PSCmdlet.ShouldProcess($branch.FriendlyName, "Remove branch")) {
                    Remove-GitBranch
                }
            }
        }
    }
}
