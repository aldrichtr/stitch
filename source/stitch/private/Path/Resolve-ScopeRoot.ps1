
function Resolve-ScopeRoot {
  <#
  .SYNOPSIS
    Resolve the root directory for all stitch data for the given scope
  #>
  [CmdletBinding()]
  param(
    # The scope at which to look-up the directory
    [Parameter(
    )]
    [Scope]$Scope = [Scope]::Local
  )

  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    $state = Get-StitchState
  }
  process {
    $roots = $state.Configuration.Scope

    if ($null -ne $roots) {
      Write-Debug "Looking up root directory for $Scope"
      $roots[$Scope.ToString()]
    } else {
      Write-Debug "Could not find Scope configuration in State"
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
