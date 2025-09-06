
function Reset-StitchState {
  <#
  .SYNOPSIS
    Return the state to the defaults
  #>
  [CmdletBinding()]
  param(
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    Write-Debug "Attempting to remove current state"
    if ($null -ne $Script:StitchState) {
      Write-Debug "- Found it.  Removing"
      $Script:StitchState = $null
    }
    Write-Debug "Creating new state object"
    Get-StitchState
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
