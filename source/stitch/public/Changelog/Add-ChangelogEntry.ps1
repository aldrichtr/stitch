
function Add-ChangelogEntry {
    <#
    .SYNOPSIS
        Add an entry to the changelog
    #>
    [CmdletBinding()]
    param(
        # The commit to add
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [PSTypeName('Git.ConventionalCommitInfo')][Object]$Commit,

        # Specifies a path to the changelog file
        [Parameter(
            Position = 0
        )]
        [Alias('PSPath')]
        [string]$Path,

        # The release to add the entry to
        [Parameter(
            Position = 2
        )]
        [string]$Release = 'unreleased'
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        enum DocumentState {
            NONE = 0
            RELEASE = 1
            GROUP = 2
        }
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $group = $Commit | Resolve-ChangelogGroup
        Write-Debug "Commit $($Commit.MessageShort) resolves to group $($group.DisplayName)"

        if (Test-Path $Path) {
            Write-Debug "Now parsing $Path"
            [Markdig.Syntax.MarkdownDocument]$doc = $Path | Import-Markdown -TrackTrivia
            $state = [DocumentState]::NONE
            $tokenCount = 0
            foreach ($token in $doc) {
                Write-Debug "--- $state : Line $($token.Line) $($token.GetType()) Index $($doc.IndexOf($token))"
                switch ($token.GetType()) {
                    'Markdig.Syntax.HeadingBlock' {
                        switch ($token.Level) {
                            2 {
                                Write-Debug "  - Is a level 2 heading"
                                $text = $token | Format-HeadingText -NoLink
                                if ($text -match [regex]::Escape($Release)) {
                                    Write-Debug "  - *** Heading '$text' matches $Release ***"
                                    $state = [DocumentState]::RELEASE
                                } else {
                                    Write-Debug "  - $text did not match"
                                }
                                continue
                            }
                            3 {
                                Write-Debug "  - Is a level 3 heading"
                                if ($state -eq [DocumentState]::RELEASE) {
                                    $text = $token | Format-HeadingText -NoLink
                                    if ($text -like $group.DisplayName) {
                                        Write-Debug "  - *** Heading '$text' matches group ***"
                                        $state = [DocumentState]::GROUP
                                    }
                                } else {
                                    Write-Debug "  - Not in release"
                                }
                                continue
                            }
                            Default {}
                        }
                        continue
                    }
                    'Markdig.Syntax.ListBlock' {
                        if ($state -eq [DocumentState]::GROUP) {
                            Write-Debug "Listblock while GROUP is set"
                            $text = $Commit | Format-ChangelogEntry
                            Write-Debug "Wanting to add '$text' to the list"
                            Write-Debug "$($token.Count) items in the list"
                            # $conversion = $text | ConvertFrom-Markdown | Select-Object -ExpandProperty Tokens |
                            # Select-Object -First 1
                            $text = "$([System.Environment]::NewLine)$text"
                            $entry = [Markdig.Markdown]::Parse($text, $true)


                            Write-Debug "The entry we want to add is a $($entry.GetType()) at $tokenCount"
                            try {
                                $doc.Insert($doc.IndexOf($token), $entry)

                            }
                            catch {
                                $PSCmdlet.ThrowTerminatingError($_)
                            } finally {
                                $state = [DocumentState]::NONE
                            }
                        }
                        continue
                    }
                    'Markdig.Syntax.LinkReferenceDefinitionGroup' {
                        $doc.RemoveAt($doc.IndexOf($token))
                    }
                }
                $tokenCount++
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $doc | Write-MarkdownDocument | Out-File $Path
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
