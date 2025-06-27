
function Format-ChangelogRelease {
    <#
    .SYNOPSIS
        Format the heading for a release in the changelog by replacing tokens form the config file with thier values
    .DESCRIPTION
        Format-ChangelogRelease uses the Format.Release line from the config file to format the Release heading in
        the Changelog.
        The following fields are available in a Release:

        | Field             | Pattern                  |
        |-------------------|--------------------------|
        | Name              | `{name}`                 |
        | Date              | `{date}`                 |
        | Date with Format  | `{date yyyy-MM-dd}`      |

    >EXAMPLE
        $release | Format-ChangelogRelease

    #>
    [CmdletBinding()]
    param(
        # A table of information about a release
        [Parameter(
            ValueFromPipeline
        )]
        [object]$ReleaseInfo
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        $DEFAULT_FORMAT = '## [{name}] - {date yyyy-MM-dd}'

        $config = Get-ChangelogConfig

        $formatOptions = $config.Format.Release ?? $DEFAULT_FORMAT
        $namePattern = '\{name\}'
        $datePattern = '\{date\}'
        $dateFormatPattern = '\{date (?<df>.*?)\}'

    } process {

        Write-Debug " Items: $($ReleaseInfo.Keys)"
        $format = $formatOptions -replace $namePattern, $ReleaseInfo.Name

        # date
        if (-not([string]::IsNullorEmpty($ReleaseInfo.Timestamp))) {
            if ($format -match $dateFormatPattern) {
                if ($ReleaseInfo.Timestamp -is [System.DateTimeOffset]) {
                    $dateText = (Get-Date $ReleaseInfo.Timestamp.UtcDateTime -Format $dateFormat)
                } else {
                    $dateText = (Get-Date $ReleaseInfo.Timestamp -Format $dateFormat)
                }

                $dateField = $Matches.0 # we want to replace the whole field so store that
                $dateFormat = $Matches.df # the format of the datetime object

                $format = $format -replace $dateField , $dateText
            } else {
                $format = $format -replace $datePattern, $ReleaseInfo.Timestamp
            }
        }
    } end {
        $format
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
