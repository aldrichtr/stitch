
function Add-StitchProfile {
  <#
    .SYNOPSIS
        Add a Build Profile to the stitch configuration
    #>
  [CmdletBinding()]
  param(
    # The name of the profile to add
    [Parameter(
    )]
    [string]$Name,

    # The parent profile
    [Parameter(
    )]
    [string]$Parent,

    # Whether the new profile inherits configuration from the parent
    [Parameter(
    )]
    [switch]$Inherit,

    # A brief description associated with the profile
    [Parameter(
    )]
    [string]$Description,

    # The scope to add the profile to.  All profiles exist in all scopes, but the profiles can be defined at any
    # level
    [Parameter(
    )]
    [Scope]$Scope,

    # Create the profile file if it does not exist
    [Parameter(
    )]
    [switch]$Force
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    $modConfig = Import-Configuration |
      Select-Object -ExpandProperty Profiles
  }
  process {
    $root = Resolve-ScopeConfigurationPath -Scope:$Scope
    $file = (Join-Path $root $modConfig.File)
    $directory = (Join-Path $root $modConfig.Directory)

    if ($file | Test-Path) {
      $profiles = $file | ConvertTo-Psd

      $existing = $profiles |
        Where-Object name -Like $Name

      if ($existing) {
        if ($Force) {
          $profiles.Remove($existing)
        } else {
          throw "Profile '$Name' already exists.  Use '-Force' to overwrite"
        }
      }

      $profiles += @{
        Name        = $Name
        Description = $Description
        Parent      = $Parent
        Inherit     = $Inherit
      }
      $profiles | ConvertTo-Psd | Set-Content $file
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
