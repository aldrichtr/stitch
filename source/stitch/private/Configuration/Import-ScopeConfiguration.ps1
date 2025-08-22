
function Import-ScopeConfiguration {
  <#
    .SYNOPSIS
      Create a unified Configuration object from files in the given path
  #>
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
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
  process {
    if (-not ($PSBoundParameters.ContainsKey('Scope'))) {
      $Scope = [Scope]::Local
    }

    $stitchPaths = Get-StitchConfigurationPath
    $configPath = $stitchPaths |
      Select-Object -ExpandProperty $Scope

    if ($null -ne $configPath) {
      $config = @{}
      if (Test-Path -Path $configPath -PathType Container) {
        foreach ($file in Get-ChildItem -Path $configPath -Filter '*.psd1' -File) {
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
    }

  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }

}
