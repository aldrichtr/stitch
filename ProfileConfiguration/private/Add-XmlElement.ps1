
using namespace System.Xml

function Add-XmlElement {
    <#
     .SYNOPSIS
        Add an element with the given name to the XmlElement given
    #>
    [OutputType([System.Xml.XmlElement])]
    [CmdletBinding()]
    param(
        # The XmlElement to Add the new element to
        [Parameter(
            Mandatory
        )]
        [XmlElement]$Xml,

        # The name of the new element
        [Parameter(
            Mandatory
        )]
        [string]$Name
    )

    try {
        $child = $Xml.OwnerDocument.CreateElement($Name)
    } catch {
        throw "Could not create new element`n$_"
    }

    try {
        $Xml.AppendChild($child)
    } catch {
        throw "Could not append new element`n$_"
    }
}
