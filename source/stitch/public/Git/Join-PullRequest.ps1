function Join-PullRequest {
    <#
    .SYNOPSIS
        Merge the current branch's pull request, then pull them into '$DefaultBranch' (usually 'main' or 'master')
    .DESCRIPTION
        Ensuring the current branch is up-to-date on the remote, and that it has a pull-request,
        this function will then:
        1. Merge the current pull request
        1. Switch to the `$DefaultBranch` branch
        1. Pull the latest changes
    #>
    param(
        # The name of the repository.  Uses the current repository if not specified
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$RepositoryName,

        # By default the remote and local branches are deleted if successfully merged.  Add -DontDelete to
        # keep the branches
        [Parameter()]
        [switch]$DontDelete,


        # The default branch. usually 'main' or 'master'
        [Parameter(
        )]
        [string]$DefaultBranch

    )
    if (-not($PSBoundParameters.ContainsKey('RepositoryName'))) {
        $PSBoundParameters['RepositoryName'] = (Get-GitRepository | Select-ExpandProperty RepositoryName)
    }

    $status = Get-GitStatus
    if ($status.IsDirty) {
        throw "Changes exist in working directory.`nCommit or stash them first"
    } else {
        if (-not ($PSBoundParameters.ContainsKey('DefaultBranch'))) {
            $DefaultBranch = Get-GitHubDefaultBranch
        }

        if ([string]::IsNullorEmpty($DefaultBranch)) {
            throw "Could not determine default branch.  Use -DefaultBranch parameter to specify"
        }

        $branch = Get-GitBranch -Current
        if ($null -ne $branch) {
            #-------------------------------------------------------------------------------
            #region Merge PullRequest
            Write-Debug "Getting Pull Request for branch $($branch.FriendlyName)"
            $pr = $branch | Get-GitHubPullRequest
            if ($null -ne $pr) {
                Write-Verbose "Merging Pull Request # $($pr.number)"
                try {
                    if ($DontDelete) {
                        $pr | Merge-GitHubPullRequest
                        Write-Verbose ' - (remote branch not deleted)'
                    } else {
                        $pr | Merge-GitHubPullRequest -DeleteBranch
                        Write-Verbose ' - (remote branch deleted)'
                    }
                } catch {
                    throw "Could not merge Pull Request`n$_"
                }

                #endregion Merge PullRequest
                #-------------------------------------------------------------------------------

                #-------------------------------------------------------------------------------
                #region Pull changes
                try {
                    Write-Verbose "Switching to branch '$DefaultBranch'"
                    Set-GitHead $DefaultBranch
                }
                catch {
                    throw "Could not switch to branch $DefaultBranch`n$_"
                }

                try {
                    Write-Verbose 'Pulling changes from remote'
                    Receive-GitBranch
                    Write-Verbose "Successfully merged pr #$($pr.number) and updated project"
                }
                catch {
                    throw "Could not update $DefaultBranch`n$_"
                }
                #endregion Pull changes
                #-------------------------------------------------------------------------------

                try {
                    Remove-GitBranch $branch
                }
                catch {
                    throw "Could not delete local branch $($branch.FriendlyName)"
                }
            } else {
                throw "Couldn't find a Pull Request for $($branch.FriendlyName)"
            }
        } else {
            throw "Couldn't get the current branch"
        }
    }
}
