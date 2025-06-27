function Add-MarkdownElement {
    [CmdletBinding()]
    param(
        # Markdown element(s) to add to the document
        [Parameter(
            Position = 0
        )]
        [Object]$Element,

        # The document to add the element to
        [Parameter(
            Position = 1,
            ValueFromPipeline
        )]
        [ref]$Document,

        # Index to insert the Elements to, append to end if not specified
        [Parameter(
            Position = 2
        )]
        [int]$Index,

        # Return the updated document to the pipeline
        [Parameter(
        )]
        [switch]$PassThru
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
    } end {
        if ($PSBoundParameters.ContainsKey('Index')) {
            $Document.Value.Insert($Index, $Element)
        } else {
            $Document.Value.Add($Element)
        }

#        if ($PassThru) { $Document.Value | Write-Output -NoEnumerate }
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
