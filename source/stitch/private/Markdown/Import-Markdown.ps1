
function Import-Markdown {
    [CmdletBinding()]
    [OutputType([Markdig.Syntax.MarkdownDocument])]
    param(
        # A markdown file to be converted
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # Additional extensions to add
        # Note advanced and yaml already added
        [Parameter(
        )]
        [string[]]$Extension,

        # Enable track trivia
        [Parameter(
        )]
        [switch]$TrackTrivia
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        try {
            $content = Get-Content $Path -Raw
            $builder = New-Object Markdig.MarkdownPipelineBuilder

            $builder = [Markdig.MarkdownExtensions]::Configure($builder, 'advanced+yaml')
            $builder.PreciseSourceLocation = $true
            if ($TrackTrivia) {
                $builder = [Markdig.MarkdownExtensions]::EnableTrackTrivia($builder)
            }
            [Markdig.Syntax.MarkdownDocument]$document = [Markdig.Parsers.MarkdownParser]::Parse(
                $content ,
                $builder.Build()
            )

            $PSCmdlet.WriteObject($document, $false)
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
