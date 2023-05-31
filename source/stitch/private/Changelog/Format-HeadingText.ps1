
function Format-HeadingText {
    <#
    .SYNOPSIS
        If the given Heading Block is a LinkInline, recreate the markdown link text, if not return the headings
        content
    .EXAMPLE
        $heading | Format-HeadingText
    .EXAMPLE
        $heading | Format-HeadingText -NoLink
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline
        )]
        [Markdig.Syntax.HeadingBlock]$Heading,

        # Return the text only without link markup
        [Parameter(
        )]
        [switch]$NoLink
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $headingText = ''
    }
    process {
        $child = $Heading.Inline.FirstChild
        while ($null -ne $child) {
            if ($child -is [Markdig.Syntax.Inlines.LinkInline]) {
                if ($NoLink) {
                    $headingText = $child.FirstChild.Content.ToString()
                }else {
                    Write-Debug ' - creating link text'
                    $headingText += ( -join ('[', $child.FirstChild.Content.ToString(), ']'))
                    Write-Debug "    - $headingText"
                    $headingText += ( -join ('(', $child.Url, ')' ))
                    Write-Debug "    - $headingText"
                }
            } else {
                $headingText += $child.Content.ToString()
            }
            $child = $child.NextSibling
        }
    }
    end {
        $headingText
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
