
using namespace System.Collections
function Select-TableItem {
  <#
  .SYNOPSIS
    Confirm or create the given table item
  .EXAMPLE
    $config | Select-TableItem $keys
  #>
  [CmdletBinding()]
  param(
    # The table to look in
    [Parameter(
      Position = 1,
      ValueFromPipeline
    )]
    [ref]$Table,

    # The item to verify
    [Parameter(
      Position = 0
    )]
    [string[]]$Keys
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    if ([string]::IsNullorEmpty($Keys)) {
      # We've reached the end of the list of keys so we are at our
      # desired Table Item, so return it and end the recursion
      $Table
    } else {
      # pop the next value of the list
      $key = $Keys[0]
      $isIndex = ($key -match '^\d+$')

      if ($isIndex) {
        if ($Table.Value -is [IList]) {
          # It is an array, now verify the index given and return that
          $index = [int]$key
          if ($index -le $Table.Value.Count) {
            [void][ArrayList]($Table.Value).Insert($index, $null)
          } else {
            Write-Debug "The index $index is outside the collection"
            $startingIndex = $Table.Value.Count
            for ($i = $startingIndex; $i -le $index; $i++) {
              [void][ArrayList]($Table.Value).Add($null)
            }
          }
          $Table = [ref]$Table.Value[$index]
        }
      } elseif ($Table.Value -is [hashtable]) {
        if (-not ($Table.Value.ContainsKey($key))) {
          $Table.Value[$key] = @{}
        }
        $Table = [ref]($Table.Value[$key])
      }
    }

    $Table | Select-TableItem ([ArrayList]$Keys.RemoveAt(0))
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
