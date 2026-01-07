
using namespace System.Collections

function Update-TableItem {
  <#
  .SYNOPSIS
    Insert or replace the given item
  .EXAMPLE
    $fileConfig | Update-TableItem $currentTable
  #>
  [CmdletBinding()]
  param(
    # The object to update with
    [Parameter(
      Position = 2,
      ValueFromPipeline
    )]
    [Object]$Item,

    # The Table to insert the item to
    [Parameter(
      Position = 0
    )]
    [ref]$Table,

    # The path to the location to update the table
    [Parameter(
      Position = 1
    )]
    [string]$Key


  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    $Table | Find-TableItem $Key
    $Table.Value = $Item

  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
