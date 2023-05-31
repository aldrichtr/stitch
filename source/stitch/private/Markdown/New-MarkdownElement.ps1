function New-MarkdownElement {
    [CmdletBinding(
        ConfirmImpact = 'Low'
    )]
    param(
        # Text to parse into Markdown Element(s)
        [Parameter(
            ValueFromPipeline
        )]
        [string[]]$InputObject
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $collect = @()
    } process {
        $collect += $InputObject
    } end {
        [Markdig.Markdown]::Parse(
            ($collect -join [System.Environment]::NewLine) ,
            $true
        ) | Write-Output -NoEnumerate
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
