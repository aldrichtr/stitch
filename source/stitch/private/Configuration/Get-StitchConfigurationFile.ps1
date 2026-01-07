
function Get-StitchConfigurationFile {
  <#
  .SYNOPSIS
    Return the configuration files in the given directory that match the configured filetypes
  #>
  [CmdletBinding()]
  param(
    # Specifies a path to one or more locations.
    [Parameter(
      Position = 0,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [Alias('PSPath')]
    [string[]]$Path,

    # The name of the config file to return
    [Parameter(
    )]
    [string]$Name
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    $state = Get-StitchState
    $options = @{
      Path = $Path
      Recurse = $true
    }
    Get-ChildItem @options |
      Where-Object {
        ($_.Extension -in $state.Configuration.FileTypes) -and (
          (-not ($PSBoundParameters.ContainsKey('Name'))) -or
          ($_.Name -like $Name)) }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
