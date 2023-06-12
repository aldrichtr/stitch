function Get-MarkdownHeading {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline
        )]
        [Markdig.Syntax.MarkdownObject[]]$InputObject
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if ($PSItem -is [Markdig.Syntax.HeadingBlock]) {
            $PSItem | Write-Output
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
