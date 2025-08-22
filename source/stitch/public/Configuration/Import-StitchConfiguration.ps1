
function Import-StitchConfiguration {
  <#
  .SYNOPSIS
    Return the stitch configuration object.  Settings are combined from the system, user, and local scopes in
    that order , unless overridden by the `-Scope` parameter.
  .DESCRIPTION
    `Import-StitchConfiguration` is one function that is
  .NOTES
    -. Starting at the "lowest" scope (System < User < Local), for each scope:
      - Build and merge the configuration for this scope : `Import-ScopeConfiguration`.
        - Build and merge the configuration for the profile at this scope : Import-ProfileConfiguration`
          -. Get the list of profiles that must be merged at this scope : `Get-ProfileTree`
            -. For each profile in the list, resolve the path to that profile's directory `Resolve-ProfilePath`
            -. For each file in the resolved directory, convert and merge its contents into BuildConfig : `Convert-ConfigurationFile`


  #>
  [CmdletBinding()]
  param(
    # Specifies the scope of the configuration to retrieve.
    # Valid values are 'Local', 'User', and 'System'.
    [Parameter(
      Position = 0,
      ValueFromPipelineByPropertyName
    )]
    [Scope]$Scope,

    # Optionally return the configuration as a hash table instead of a Stitch.ConfigurationInfo object.
    [Parameter(
    )]
    [switch]$AsHashtable
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    $paths = Import-Configuration
    | Select-Object -ExpandProperty Configuration
  }
  process {
    $stitchConfig = @{}
    if (-not ($PSBoundParameters.ContainsKey('Scope'))) {
      $Scope = [Scope]::Local
    }

    foreach ($s in @(0..2)) {
      if ($Scope.HasFlag([Scope]($s))) {
        $scopeConfig = Import-ScopeConfiguration -Scope $Scope
        $stitchConfig = $stitchConfig | Update-Object $scopeConfig
      }
    }

    if ($AsHashtable) {
      $stitchConfig
    } else {
      $stitchConfig['PSTypeName'] = 'Stitch.ConfigurationInfo'
      [PSCustomObject]$stitchConfig
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}
