

function Format-ChangelogHeader {
    <#
    .SYNOPSIS
        Format the header in the Changelog
    .EXAMPLE
        Format-ChangelogHeader
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $DEFAULT_FORMAT = ''
        $config = Get-ChangelogConfig

        if (-not([string]::IsNullorEmpty($config.Header))) {
            $formatOptions  = $config.Header
        } else {
            $formatOptions = $DEFAULT_FORMAT
        }
    }
    process {
        #! There are no replacements in the header yet
        $format = $formatOptions
    }
    end {
        $format
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
