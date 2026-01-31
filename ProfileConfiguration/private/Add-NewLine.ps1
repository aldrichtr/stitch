
using namespace System.Xml

function Add-NewLine {
    <#
    .SYNOPSIS
        Add a NewLine element to the given XmlElement
    #>
    [CmdletBinding()]
    param(
        # The Xml Element to add the newline to
        [Parameter(
        )]
        [XmlElement]$Element
    )
    begin {
        $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
        $NL_NAME = 'NewLine'
    }
    process {
        $newLine = $Element.OwnerDocument.CreateElement($NL_NAME)

        $Element.AppendChild($newLine)
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
    }
}
