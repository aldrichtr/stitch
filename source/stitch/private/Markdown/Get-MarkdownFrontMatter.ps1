function Get-MarkdownFrontMatter {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline
        )]
        [Markdig.Syntax.MarkdownDocument]$InputObject
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Get-MarkdownElement -InputObject $InputObject -TypeName 'Markdig.Extensions.Yaml.YamlFrontMatterBlock'
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
