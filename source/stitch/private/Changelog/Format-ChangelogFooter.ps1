

function Format-ChangelogFooter {
    <#
    .SYNOPSIS
        Format the footer in the Changelog
    .EXAMPLE
        Format-ChangelogFooter
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $DEFAULT_FORMAT = ''
        $config = Get-ChangelogConfig

        if (-not([string]::IsNullorEmpty($config.Footer))) {
            $formatOptions = $config.Footer
        } else {
            $formatOptions = $DEFAULT_FORMAT
        }
    } process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        #! There are no replacements in the footer yet
        $format = $formatOptions
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    } end {
        $format
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
