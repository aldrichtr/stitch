
function Get-GitHistory {
    [CmdletBinding()]
    param()

    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $config = Get-ChangelogConfig

        $currentVersion = $config.CurrentVersion ?? 'unreleased'

        $releases = @{
            $currentVersion = @{
                Name = $currentVersion
                Timestamp = (Get-Date)
                Groups = @{}
            }
        }
    }
    process {

        foreach ($commit in Get-GitCommit) {
            #-------------------------------------------------------------------------------
            #region Convert commit message
            Write-Debug "Converting $($commit.MessageShort)"
            try {
                $commitObject = $commit | ConvertFrom-ConventionalCommit
            }
            catch {
                $exception = [Exception]::new("Could not convert commit $($commit.MessageShort)`n$($_.PSMessageDetails)")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    $_.FullyQualifiedErrorId,
                    $_.CategoryInfo,
                $commit
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
            #endregion Convert commit message
            #-------------------------------------------------------------------------------



            if ($null -ne $commit.Refs) {
                foreach ($ref in $commit.Refs) {
                    $name = $ref.CanonicalName -replace '^refs\/', ''
                    if ($name -match '^tags\/(?<tag>.*)$') {
                        Write-Debug '    - is a tag'
                        $commitObject | Add-Member -NotePropertyName Tag -NotePropertyValue $Matches.tag
                        if ($commitObject.Tag -match $config.TagPattern) {
                            # Add a version to the releases
                            $currentVersion = $Matches.1
                            $releases[$currentVersion] = @{
                                Name = $currentVersion
                                Timestamp = (Get-Date '1970-01-01') # set it as the epoch, but update below
                                Groups    = @{}
                            }
                            if ($null -ne $commitObject.Author.When.UtcDateTime) {
                                $releases[$currentVersion].Timestamp = $commitObject.Author.When.UtcDateTime
                            }
                        }
                    }
                }
            }

            #-------------------------------------------------------------------------------
            #region Add to group

            $group = $commitObject | Resolve-ChangelogGroup

            if ($null -eq $group) {
                Write-Debug "no group information found for $($commitObject.MessageShort)"
                $group = @{
                    Name = 'Other'
                    DisplayName = 'Other'
                    Sort = 99999
                }
            }
                if (-not($releases[$currentVersion].Groups.ContainsKey($group.Name))) {
                    $releases[$currentVersion].Groups[$group.Name] = @{
                        DisplayName = $group.DisplayName
                        Sort = $group.Sort
                        Entries = @()
                    }
                }
                $releases[$currentVersion].Groups[$group.Name].Entries += $commitObject

            #endregion Add to group
            #-------------------------------------------------------------------------------
        }
    }
    end {

        $releases | Write-Output
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
