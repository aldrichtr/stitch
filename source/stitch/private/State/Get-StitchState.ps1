
function Get-StitchState {
  <#
  .SYNOPSIS
    Retrieve the current state of the stitch module
  #>
  [CmdletBinding()]
  param(
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    # NOTE: Script scope is module scope for powershell modules
    # Which means this variable will exist for all stitch functions in this instance of the module.
    # It is not guaranteed to be the same in other powershell processes or runspaces
    if ($null -eq $Script:StitchState) { $Script:StitchState = New-StitchState }

    $Script:StitchState
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
