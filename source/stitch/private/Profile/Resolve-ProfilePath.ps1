
function Resolve-ProfilePath {
  <#
  .SYNOPSIS
    Resolve the Path to the given [Stitch.Profile] at the given Scope
  .DESCRIPTION
    This function contributes to `Get-StitchConfiguration`, by   It uses the Name of the profile and the Scope to
    determine the path to the folder that holds the configuration files for the profile at the scope.  It does not
    guarantee the path exists, and will return $null if not found
  #>
  [CmdletBinding()]
  param(
  # The name of the profile to resolve.  `default` if not specified.
  [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName
  )]
  [string]$Name,

  # The scope at which to look-up the profile
  [Parameter(
  )]
  [Scope]$Scope
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    $modConfig = Import-Configuration
    $profileDir = $modConfig?.Profiles?.Directory ?? 'profiles'
  }
  process {
    if (-not ($PSBoundParameters.ContainsKey('Name'))) { $Name = 'default' }

    if (-not ($PSBoundParameters.ContainsKey('Scope'))) { $Scope = [Scope]::Local }

    $scopeRoot = Resolve-ScopeConfigurationPath $Scope

    Write-Debug "Looking in $scopeRoot for profile $Name"
    if ($Name -like 'default') {
      $scopeRoot
    } else {
      $profileRoot = (Join-Path $scopeRoot $profileDir)
      $profilePath = (Join-Path $profileRoot $Name)
      if ($profilePath | Test-Path) {
        Get-Item $profilePath
      }
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
