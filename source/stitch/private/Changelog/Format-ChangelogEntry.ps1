
function Format-ChangelogEntry {
    <#
    .SYNOPSIS
        Format the entry text by replacing tokens from the config file with their values
    .DESCRIPTION
        Format-ChangelogEntry uses the Format.Entry line from the config file to format the Entry line in the
        Changelog.
        The following fields are available in an Entry:
        | Field       | Pattern       |
        |-------------|---------------|
        | Description | `{desc}`      |
        | Type        | `{type}`      |
        | Scope       | `{scope}`     |
        | Title       | `{title}`     |
        | Sha         | `{sha}`       |
        | Author      | `{author}`    |
        | Email       | `{email}`     |
        | Footer      | `{ft.<name>}` |
    .EXAMPLE
        $Entry | Format-ChangelogEntry
    #>
    [CmdletBinding()]
    param(
        # Information about the Entry (commit) object
        [Parameter(
            ValueFromPipeline
        )]
        [object]$EntryInfo
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        $DEFAULT_FORMAT = '- {sha} {desc} ({author})'
        $DEFAULT_BREAKING_FORMAT = '- {sha} **breaking change** {desc} ({author})'

        $config = Get-ChangelogConfig

        $descriptionPattern = '\{desc\}'
        $typePattern = '\{type\}'
        $scopePattern = '\{scope\}'
        $titlePattern = '\{title\}'
        $shaPattern = '\{sha\}'
        $authorPattern = '\{author\}'
        $emailPattern = '\{email\}'
        $footerPattern = '\{ft\.(\w+)\}'

    } process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        if ($EntryInfo.IsBreakingChange) {
            $formatOptions = $config.Format.BreakingChange ?? $DEFAULT_BREAKING_FORMAT
        } else {
            $formatOptions = $config.Format.Entry ?? $DEFAULT_FORMAT
        }

        $format = $formatOptions -replace $descriptionPattern , $EntryInfo.Description
        $format = $format -replace $typePattern , $EntryInfo.Type
        $format = $format -replace $scopePattern , $EntryInfo.Scope
        $format = $format -replace $titlePattern , $EntryInfo.Title
        $format = $format -replace $shaPattern , $EntryInfo.ShortSha
        $format = $format -replace $authorPattern , $EntryInfo.Author.Name
        $format = $format -replace $emailPattern , $EntryInfo.Author.Email


        if ($format -match $footerPattern) {
            if ($matches.Count -gt 0) {
                if ($EntryInfo.Footers[$Matches.1]) {
                    $format = $format -replace "\{ft\.$($Matches.1)\}", ($EntryInfo.Footers[$Matches.1] -join ', ')
                }
            }
        }

        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    } end {
        $format
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
