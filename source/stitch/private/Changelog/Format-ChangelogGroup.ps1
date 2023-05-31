
function Format-ChangelogGroup {
    <#
    .SYNOPSIS
        Format the heading of a group of changelog entries
    .EXAMPLE
        $group | Format-ChangelogGroup
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # A table of information about a changelog group
        [Parameter(
            ValueFromPipeline
        )]
        [object]$GroupInfo
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        $DEFAULT_FORMAT = '### {name}'

        $config = Get-ChangelogConfig

        $formatOptions = ($config.Format.Group ?? $DEFAULT_FORMAT)
        $namePattern = '\{name\}'
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        Write-Debug "Format was '$formatOptions'"
        Write-Debug "GroupInfo is $($GroupInfo | ConvertTo-Psd)"
        if (-not ([string]::IsNullorEmpty($GroupInfo.DisplayName))) {
            Write-Debug "  - DisplayName is $($GroupInfo.DisplayName)"
            $format = $formatOptions -replace $namePattern, $GroupInfo.DisplayName
        } elseif (-not ([string]::IsNullorEmpty($GroupInfo.Name))) {
            $format = $formatOptions -replace $namePattern, $GroupInfo.Name
            Write-Debug "  - Name is $($GroupInfo.Name)"
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "Format is '$format'"
        $format
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
