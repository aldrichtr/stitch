
function Set-StitchConfigurationPath {
  <#
    .SYNOPSIS
        Change the path to the Stitch configuration directory.
    #>
  [CmdletBinding(
    SupportsShouldProcess,
    ConfirmImpact = 'Medium'
  )]
  param(
    # Specifies a path to use as the location where stitch looks for configuration files of the given scope.
    [Parameter(
    Position = 0,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName
    )]
    [Alias('PSPath')]
    [string]$Path,

    # Specifies the scope of the configuration path.
    # Valid values are 'Local', 'User', and 'System'.
    # 'Local' refers to the current session, 'User' refers to the current user profile, and 'System' refers to the
    # system-wide configuration.
    # If not specified, defaults to 'Local'.
    [Parameter(
    Position = 1,
    ValueFromPipelineByPropertyName
    )]
    [ValidateSet('Local', 'User', 'System')]
    [string]$Scope = 'Local'
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    $config = Import-Configuration # This is from the `Configuration` module

  }
  process {
    if ($PSCmdlet.ShouldProcess("Set Stitch configuration path to '$Path' for scope '$Scope'")) {
      # Validate the provided path
      if (-not (Test-Path -Path $Path -PathType Container)) {
        throw "The specified path '$Path' does not exist or is not a directory."
      }

      # Set the configuration path based on the scope
      switch ($Scope) {
        'Local' {
          $config.Configuration.Local = $Path
        }
        'User' {
          $config.Configuration.User = $Path
        }
        'System' {
            $config.Configuration.System = $Path
        }
      }
      $config | Export-Configuration -Force
      Write-Verbose "Configuration path for scope '$Scope' set to '$Path'."
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
