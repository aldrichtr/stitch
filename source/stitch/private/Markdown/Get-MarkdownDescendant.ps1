
using namespace Markdig
using namespace Markdig.Syntax
function Get-MarkdownDescendant {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline
        )]
        [MarkdownObject]$InputObject,

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
        if ($PSBoundParameters.ContainsKey('TypeName')) {

            #Check Type
            $type = $TypeName -as [Type]
            if (-not $type) {
                throw "Type: '$TypeName' not found"
            }
            $methodDescendants = [MarkdownObjectExtensions].GetMethod('Descendants', 1, [MarkdownObject])
            $mdExtensionsType = [MarkdownObjectExtensions]
            $method = $methodDescendants.MakeGenericMethod($Type)
            $method.Invoke($mdExtensionsType, @(, $InputObject)) | ForEach-Object { $PSCmdlet.WriteObject($_, $false) }
        } else {
            [MarkdownObjectExtensions]::Descendants($InputObject)
        }

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
