
function Set-ChangelogRelease {
    <#
    .SYNOPSIS
        Create a new release section in the Changelog based on the changes in 'Unreleased' and creates a new blank
        'Unreleased' section
    #>
    [Alias('Update-Changelog')]
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'medium'
    )]
    param(
        # Specifies a path to the changelog file
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # The unreleased section will be moved to this version
        [Parameter(
        )]
        [string]$Release,

        # The date of the release
        [Parameter(
        )]
        [datetime]$releaseDate,

        # Skip checking the current git tag information
        [Parameter(
        )]
        [switch]$SkipGitTag
    )
    begin {
        Write-Verbose "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $config = Get-ChangelogConfig
        if (-not($SkipGitTag)) {
            if ($PSBoundParameters.ContainsKey('Release')) {
                $tag = Get-GitTag -Name $Release -ErrorAction SilentlyContinue
            } else {
                $tag = Get-GitTag | Where-Object {
                    $_.Name -match $config.TagPattern
                } |  Select-Object -First 1 -ErrorAction SilentlyContinue
            }

            if ($null -ne $tag) {
                $releaseDate = $tag.Target.Author.When.UtcDateTime
                if ($null -ne $Release) {
                    $null = $tag.FriendlyName -match $config.TagPattern
                    if ($Matches.Count -gt 0) {
                        $Release = $Matches.1
                    }
                }
            } else {
                $PSCmdlet.WriteError("Could not find tag $Release")
            }
        }
        if ([string]::IsNullorEmpty($Release)) {
            throw "No Release version could be found"
        }

        if ([string]::IsNullorEmpty($ReleaseDate)) {
            $PSCmdlet.WriteError("No release date was found for release $Release")
        }
    }
    process {
        Write-Verbose "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if (Test-Path $Path) {
            Write-Verbose "Setting up temp document"
            $tempFile = [System.IO.Path]::GetTempFileName()
            Get-Content $Path -Raw | Set-Content $tempFile

            Write-Verbose "Now parsing document"
            [Markdig.Syntax.MarkdownDocument]$doc = $tempFile | Import-Markdown -TrackTrivia

            $currentVersionHeading = $doc | Get-MarkdownHeading | Where-Object {
                ($_ | Format-HeadingText -NoLink) -match $config.CurrentVersion
            }
            Write-Verbose "Found $($currentVersionHeading.Count) current version headings"

            if ($null -ne $currentVersionHeading) {
                $afterCurrentHeading = ($doc.IndexOf($currentVersionHeading) + 1)
                $releaseData = @{
                    Name = $Release
                    TimeStamp = $releaseDate
                }
                $newHeading = [Markdig.Markdown]::Parse(
                    ($releaseData | Format-ChangelogRelease),
                    $true
                )
                if ($null -ne $newHeading) {
                    $newText =$newHeading | Format-HeadingText -NoLink
                    Write-Verbose "New Heading is $newText"
                    [ref]$doc | Add-MarkdownElement $newHeading -Index $afterCurrentHeading
                    [ref]$doc | Add-MarkdownElement ([Markdig.Syntax.BlankLineBlock]::new()) -Index $afterCurrentHeading
                }
            }

            $linkRefs = $doc | Get-MarkdownElement LinkReferenceDefinitionGroup | Select-Object -First 1
            if ($null -ne $linkRefs) {
                $doc.RemoveAt($doc.IndexOf($linkRefs))
            }
            try {
                $doc | Write-MarkdownDocument | Out-File $tempFile
                #! -Force required to overwrite our file
                $tempFile | Move-Item -Destination $Path -Force
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
        Write-Verbose "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Verbose "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
