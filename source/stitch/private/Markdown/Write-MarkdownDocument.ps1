function Write-MarkdownDocument {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline
        )]
        [Markdig.Syntax.MarkdownObject]$InputObject
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $sw = [System.IO.StringWriter]::new()
        $rr = [Markdig.Renderers.Roundtrip.RoundtripRenderer]::new($sw)

        $rr.Write($InputObject)
        $sw.ToString() | Write-Output
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
