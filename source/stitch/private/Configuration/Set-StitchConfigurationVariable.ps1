
function Set-StitchConfigurationVariable {
  <#
  .SYNOPSIS
    Set the global variable `$StitchConfigHome` to the paths for the scopes
  .DESCRIPTION
    `Set-StitchConfigurationVariable` will set the `StitchConfigHome` global variable to the path for all three
    scopes similar to the `$Profile` variable.  When used as a string, it returns the Local path,
    but it includes the Properties `Local`, `User`, and `System`
  #>
  [CmdletBinding()]
  param(
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    $modConfig = Import-Configuration |
      Select-Object -ExpandProperty 'Configuration'
    if ($null -eq $modConfig) {
      throw 'Could not get module configuration'
    }
  }
  process {

    $configInfo = [psobject]([string]$modConfig.Local)
    $configInfo |
      Add-Member -NotePropertyMembers $modConfig
    Write-Debug "`$configInfo is a $($configInfo.GetType().FullName)"
    $configInfo |
      Get-Member -MemberType NoteProperty |
        ForEach-Object {
          Write-Debug "- it has $($_.Name) which is $($_.Definition)"
        }

    $Global:StitchConfigHome = $configInfo
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
