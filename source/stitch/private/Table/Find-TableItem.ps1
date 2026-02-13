
function Find-TableItem {
  <#
  .SYNOPSIS
    Recurse down into a nested table / array
  .DESCRIPTION
    Recurse dow the nested table / array creating the keys if they don't exist
  #>
  [CmdletBinding()]
  param(
    # The Configuration to update
    [Parameter(
      Position = 1,
      ValueFromPipeline
    )]
    [ref]$Table,

    # The dot-separated path to the value
    [Parameter(
      Position = 0
    )]
    [string]$Path

  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    $pathSeparator = [regex]::Escape('.')
  }
  process {
   $Table | Select-TableItem ($Path -split $pathSeparator)
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
