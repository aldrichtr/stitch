
function Import-ProfileConfiguration {
  <#
  .SYNOPSIS
    Load and merge all configuration files for the given profile and its parents
  #>
  [CmdletBinding()]
  param(
    # The name of the profile to import
    [Parameter(
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [string]$Name,

    # The scope at which to look for profiles
    [Parameter(
    )]
    [Scope]$Scope
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    #. This folder is the root underwhich all config files are stored
    $modConfig = Import-Configuration
    $configDir      = 'config'
    $buildDir = 'build'
  }
  process {

    if (-not ($PSBoundParameters.ContainsKey('Name'))) { $Name = 'default' }

    if (-not ($PSBoundParameters.ContainsKey('Scope'))) { $Scope = [Scope]::Local }

    $profilePath = Resolve-ProfilePath @PSBoundParameters
    $profileBuildConfigPath = ($profilePath | Join-Path $configDir $buildDir)

    $fileOptions = @{
        Path    = $profileBuildConfigPath
        Include = $modConfig.FileTypes
        Recurse = $true
      }
    Write-Debug "Looking for files in $profileBuildConfigPath that match $($fileOptions.Include -join ', ')"
    Get-ChildItem @fileOptions
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
