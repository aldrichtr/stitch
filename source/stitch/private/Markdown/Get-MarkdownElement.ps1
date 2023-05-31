function Get-MarkdownElement {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline
        )]
        [Markdig.Syntax.MarkdownObject]$InputObject,

        # The type of element to return
        [Parameter(
            Position = 0
        )]
        [string]$TypeName
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {

    } end {
        #Check Type
        if ($TypeName -notmatch '^Markdig\.Syntax') {
            $TypeName = 'Markdig.Syntax.' + $TypeName
        }

        $type = $TypeName -as [Type]
        if (-not $type) {
            throw "Type: '$TypeName' not found"
        }
        Write-Verbose "Looking for a $type"
        foreach ($token in $InputObject) {
            if ($token -is $type) {
                $token | Write-Output
            }
        }
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
