
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

    # The Profile to import. If not specified `default` is used
    [Parameter(
    )]
    [string]$ProfileName,

    # The path to the key in the configuration
    [Parameter(
      Position = 1
    )]
    [string]$Key,

    # Optionally return the configuration as a hash table instead of a Stitch.ConfigurationInfo object.
    [Parameter(
    )]
    [switch]$AsHashtable
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"

    $stitchConfig = @{}
  }
  process {
    # NOTE: If no Scope is given, then we want to merge all of them
    if (-not ($PSBoundParameters.ContainsKey('Scope'))) { $Scope = [Scope]::Local }
    if (-not ($PSBoundParameters.ContainsKey('ProfileName'))) { $ProfileName = 'default' }

    $tree = Resolve-ProfileTree $ProfileName
    if ($null -eq $tree) {
      Write-Warning "Could not resolve profile structure for $ProfileName.  Using 'default'"
      $tree = @('default')
    }

    Write-Debug "- Given that profile is $ProfileName, the profile-tree is $($tree -join ', ')"
    for ($i=0; $i -le [int]$Scope) {
      $currentScope = [Scope]($i)
      foreach ($branch in $tree) {
        Write-Debug "Importing configuration at $($currentScope.ToString()) for $branch"
        $scopeConfig = Import-ProfileConfiguration $branch -Scope $currentScope
        if ($null -ne $scopeConfig) {
          # NOTE: If there were any configuration items, merge them into the running configuration
          Write-Debug '- Merging that into the Configuration'
          $stitchConfig = $stitchConfig | Update-Object -UpdateObject $scopeConfig
        }
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
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
