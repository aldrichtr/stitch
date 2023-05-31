
function ConvertTo-Changelog {
    <#
    .SYNOPSIS
        Convert Git-History to a Changelog
    #>
    [CmdletBinding()]
    param(
        # A git history table to be converted
        [Parameter(
            ValueFromPipeline
        )]
        [hashtable]$History
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $config = Get-ChangelogConfig
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        Format-ChangelogHeader
        [System.Environment]::NewLine

        foreach ($releaseName in (($History.GetEnumerator() | Sort-Object { $_.Value.Timestamp } -Descending | Select-Object -ExpandProperty Name))) {
            $release = $History[$releaseName]
            $release | Format-ChangelogRelease
            [System.Environment]::NewLine

            foreach ($groupName in ($release.Groups.GetEnumerator() | Sort-Object { $_.Value.Sort } | Select-Object -ExpandProperty Name)) {
                if ($groupName -like 'omit') { continue }
                $group = $release.Groups[$groupName]
                $group | Format-ChangelogGroup
                [System.Environment]::NewLine

                foreach ($entry in $group.Entries) {
                    $entry | Format-ChangelogEntry
                }
                 [System.Environment]::NewLine
            }
        }

        [System.Environment]::NewLine

        Format-ChangelogFooter

        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
