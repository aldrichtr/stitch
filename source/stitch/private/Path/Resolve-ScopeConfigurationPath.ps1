
function Resolve-ScopeConfigurationPath {
  <#
  .SYNOPSIS
    Return the path that stitch looks to for configuration files at this scope
  .DESCRIPTION
    `Resolve-ScopeConfigurationPath` Returns the path to the `config` folder in the .stitch folder in each location.
  .EXAMPLE
    Resolve-ScopeConfigurationPath

    `.stitch`
  .EXAMPLE
    Resolve-ScopeConfigurationPath | Select-Object -ExpandProperty System

    `C:\ProgramData\stitch`
    #>
  [CmdletBinding()]
  param(
    # The scope at which to look-up the profile
    [Parameter(
      Position = 0,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [Scope]$Scope = [Scope]::Local
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    $state = Get-StitchState
  }
  process {
    $scopeName = $Scope.ToString()
    Write-Debug "Looking up path for scope $($scopeName)"
    $root = Resolve-ScopeRoot -Scope $Scope
    (Join-Path $root $state.Configuration.Directory)
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
