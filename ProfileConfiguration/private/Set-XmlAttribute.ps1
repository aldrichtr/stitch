
using namespace System.Xml

function Set-XmlAttribute {
    <#
    .SYNOPSIS
        Set an attribute with the given name and value on the given element
    #>
    [CmdletBinding()]
    param(
        # The element to set the attribute on
        [Parameter(
        )]
        [XmlElement]$Element,

        # The name of the attribute
        [Parameter(
        )]
        [string]$Name,

        # the value for the attribute
        [Parameter(
        )]
        [string]$Value
    )
    begin {
        $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    }
    process {
        $Element.SetAttribute($Name, $Value)
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
    }
}
