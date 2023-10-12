
function Resolve-ChangelogGroup {
    <#
    .SYNOPSIS
        Given a git commit and a configuration identify what group the commit should be in
    .EXAMPLE
        Get-GitCommit | ConvertFrom-ConventionalCommit | Resolve-ChangelogGroup
    #>
    [CmdletBinding()]
    param(
        # A conventional commit object
        [Parameter(
            ValueFromPipeline
        )]
        [PSTypeName('Git.ConventionalCommitInfo')][Object[]]$Commit
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $config = Get-ChangelogConfig
    }
    process {
        Write-Debug "Processing Commit : $($Commit.Title)"
        foreach ($key in $config.Groups.Keys) {
            $group = $config.Groups[$key]
            $display = $group.DisplayName ?? $key
            $group['Name'] = $key
            Write-Debug "Checking group $key"
            switch ($group.Keys) {
                'Type' {
                    if (($null -ne $Commit.Type) -and
                        ($group.Type.Count -gt 0)) {
                        Write-Debug "  - Has Type entries"
                        foreach ($type in $group.Type) {
                            Write-Debug "    - Checking for a match with $type"
                            if ($Commit.Type -match $type) {
                                return $group
                            }
                        }
                    }
                    continue
                }
                'Title' {
                    if (($null -ne $Commit.Title) -and
                        ($group.Title.Count -gt 0)) {
                        Write-Debug "  - Has Title entries"
                        foreach ($title in $group.Title) {
                            Write-Debug "    - Checking for a match with $title"
                            if ($Commit.Title -match $title) {
                                return $group
                            }
                        }
                    }
                    continue
                }
                'Scope' {
                    if (($null -ne $Commit.Scope) -and
                        ($group.Scope.Count -gt 0)) {
                        Write-Debug "  - Has Scope entries"
                        foreach ($scope in $group.Scope) {
                            Write-Debug "    - Checking for a match with $scope"
                            if ($Commit.Scope -match $scope) {
                                return $group
                            }
                        }
                    }
                    continue
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
