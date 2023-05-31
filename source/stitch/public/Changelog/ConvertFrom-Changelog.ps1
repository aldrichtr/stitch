
function ConvertFrom-Changelog {
    <#
    .SYNOPSIS
        Convert a Changelog file into a PSObject
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        # Optionally return a hashtable instead of an object
        [Parameter(
        )]
        [switch]$AsHashTable
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $changelogObject = @{
            Releases = [System.Collections.ArrayList]@()
        }
    }
    process {
        foreach ($file in $Path) {
            if (Test-Path $file) {
                try {
                    Write-Debug "Importing markdown document $file"
                    $doc = Get-Item $file | Import-Markdown
                } catch {
                    throw "Error parsing markdown`n$_"
                }
            } else {
                throw "$file is not a valid path"
            }
            Write-Debug "Parsing tokens in $file"
            foreach ($token in $doc) {
                switch ($token) {
                    { $_ -is [Markdig.Syntax.HeadingBlock] } {
                        $text = $token | Format-HeadingText
                        switch ($token.Level) {
                            <#
                if this is a level 2 heading then it is a new release
                every token after this one should be added to the release
                and the group should be added to the changelog after it has been completely
                filled out
                #>
                            2 {
                                Write-Debug "at Line $($token.Line) Found new release heading '$text'"
                                if ($null -ne $thisRelease) {
                                    Write-Debug ' - Adding previous group to changelog'
                                    if ($AsHashTable) {
                                        $null = $changelogObject.Releases.Add($thisRelease)
                                    } else {
                                        $null = $changelogObject.Releases.Add([PSCustomObject]$thisRelease)
                                    }

                                    Remove-Variable release, group -ErrorAction SilentlyContinue
                                }
                                $thisRelease = @{
                                    Groups   = [System.Collections.ArrayList]@()
                                }
                                if (-not($AsHashTable)) {
                                    $thisRelease['PSTypeName'] = 'Changelog.Release'
                                }

                                # unreleased
                                if ($text -match '^\[?unreleased\]? - (.*)?') {
                                    Write-Debug '- matches unreleased'
                                    $thisRelease['Version'] = 'unreleased'
                                    $thisRelease['Name'] = 'unreleased'
                                    $thisRelease['Type'] = 'Unreleased'
                                    if ($null -ne $Matches.1) {
                                        $thisRelease['Timestamp'] = (Get-Date $Matches.1)
                                    } else {
                                        $thisRelease['Timestamp'] = (Get-Date -Format 'yyyy-MM-dd')
                                    }
                                    # version, link and date
                                    # [1.0.1](https://github.com/user/repo/compare/vprev..vcur)    1986-02-25
                                } elseif ($text -match '^\[(?<ver>[0-9\.]+)\]\((?<link>[^\)]+)\)\s*-?\s*(?<dt>\d\d\d\d-\d\d-\d\d)?') {
                                    Write-Debug '- matches version,link and date'
                                    if ($null -ne $Matches.ver) {
                                        $thisRelease['Type'] = 'Release'
                                        $thisRelease['Version'] = $Matches.ver
                                        $thisRelease['Name'] = $Matches.ver
                                        if ($null -ne $Matches.dt) {
                                            $thisRelease['Link'] = $Matches.link
                                        }
                                        if ($null -ne $Matches.dt) {
                                            $thisRelease['Timestamp'] = $Matches.dt
                                        }
                                    }
                                    # version and date
                                    # [1.0.1]   1986-02-25
                                } elseif ($text -match '^\[(?<ver>[0-9\.]+)\]\s*-?\s*(?<dt>\d\d\d\d-\d\d-\d\d)?') {
                                    Write-Debug '- matches version and date'
                                    if ($null -ne $Matches.ver) {
                                        $thisRelease['Type'] = 'Release'
                                        $thisRelease['Version'] = $Matches.ver
                                        $thisRelease['Name'] = $Matches.ver
                                        if ($null -ne $Matches.dt) {
                                            $thisRelease['Timestamp'] = $Matches.dt
                                        }
                                    }
                                }
                            }
                            3 {
                                if ($null -ne $group) {
                                    if ($AsHashTable) {
                                        $null = $thisRelease.Groups.Add($group)
                                    } else {
                                        $null = $thisRelease.Groups.Add([PSCustomObject]$group)
                                    }
                                    $group.Clear()
                                }
                                $group = @{
                                    Entries = [System.Collections.ArrayList]@()
                                }
                                $group['DisplayName'] = $text
                                $group['Name'] = $text
                                if (-not($AsHashTable)) {
                                    $group['PSTypeName'] = 'Changelog.Group'
                                }
                            }
                        }
                    }
                    { $_ -is [Markdig.Syntax.ListItemBlock] } {
                        Write-Debug "  - list item block at line $($token.Line) column $($token.Column)"
                        # token is a collection of ListItems
                        foreach ($listItem in $token) {
                            Write-Debug "    - list item at line $($listItem.Line) column $($listItem.Column)"
                            $text = $listItem.Inline.Content.ToString()
                            $null = $group.Entries.Add(
                                @{
                                    Title = $text
                                    Description = $text
                                }
                            )
                        }
                        continue
                    }
                }
            }
        }
        Write-Debug ' - adding last release to changelog'
        if ($AsHashTable) {
            $null = $changelogObject.Releases.Add($thisRelease)
        } else {
            $null = $changelogObject.Releases.Add([PSCustomObject]$thisRelease)
        }
    }
    end {
        if ($AsHashTable) {
            $changelogObject | Write-Output
        } else {
            $changelogObject['PSTypeName'] = 'ChangelogInfo'
            [PSCustomObject]$changelogObject | Write-Output
        }
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
