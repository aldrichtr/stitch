
function Import-ScopeConfiguration {
  <#
  .SYNOPSIS
    Create a unified Configuration object from files in the given path
  .OUTPUTS
    [System.Collections.Hashtable]
  #>
  [OutputType([System.Collections.Hashtable])]
  [CmdletBinding(
    SupportsShouldProcess,
    ConfirmImpact = 'Low'
  )]
  param(
    # The scope to import
    [Parameter(
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [Scope]$Scope
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    if (-not ($PSBoundParameters.ContainsKey('Scope'))) {
      $Scope = [Scope]::Local
    }

    Write-Debug "- Importing configuration for $($Scope.ToString()) scope"
    $stitchPaths = Resolve-ScopeConfigurationPath
    $configPath = $stitchPaths |
      Select-Object -ExpandProperty $Scope

    if ($null -ne $configPath) {
      $config = @{}
      if (Test-Path -Path $configPath -PathType Container) {
        foreach ($file in (Get-StitchConfigurationFile $configPath)) {
          Write-Debug "Importing configuration from file: $($file.FullName)"
          $fileConfig = Get-Content -Path $configPath | Import-Psd -Unsafe
          $config = $config | Update-Object -UpdateObject $fileConfig
        }
        return $config
      } else {
        Write-Warning "Configuration path for scope '$scope' does not exist or is not a directory."
        return @{}
      }
    } else {
      Write-Debug "No path is configured for scope $scope"
    }

  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }

}
