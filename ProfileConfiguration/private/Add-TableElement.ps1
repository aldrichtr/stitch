
using namespace System.Xml

function Add-TableElement {
    <#
    .SYNOPSIS
        Add an element to an existing table.
    .DESCRIPTION
        In PsdKit, when a hashtable is converted to xml it is as a <Table></Table> element.  This function adds the
        given element as an additional key => value to the table
    #>
    [CmdletBinding()]
    param(
        # The Table Element
        [Parameter(
        )]
        [XmlElement]$Table,

        # The element to add
        [Parameter(
        )]
        [XmlElement]$Value
    )
    begin {
        $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    }
    process {

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
    }
}
