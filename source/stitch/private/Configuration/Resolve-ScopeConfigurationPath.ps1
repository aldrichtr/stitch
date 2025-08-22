
function Resolve-ScopeConfigurationPath {
  <#
    .SYNOPSIS
      Return the path that stitch looks to for configuration files.
    .DESCRIPTION
      The object returned by `Resolve-ScopeConfigurationPath` is similar to the `$PROFILE` variable.
      There are three properties available; 'System', 'User', and 'Local'
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
    [Scope]$Scope
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    # this is from the Configuration module
    $modConfig = Import-Configuration |
      Select-Object -ExpandProperty 'Configuration'
    if ($null -eq $modConfig) {
      throw 'Could not get module configuration'
    }
  }
  process {
    if (-not ($PSBoundParameters.ContainsKey('Scope'))) {
      $Scope = [Scope]::Local
    }

    $scopePath = $modConfig[$Scope.ToString()]




  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
