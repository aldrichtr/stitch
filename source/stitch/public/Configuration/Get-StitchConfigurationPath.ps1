
function Get-StitchConfigurationPath {
  <#
    .SYNOPSIS
      Return the path that stitch looks to for configuration files.
    .DESCRIPTION
      The object returned by `Get-StitchConfigurationPath` is similar to the `$PROFILE` variable.
      There are three properties available; 'System', 'User', and 'Local'
    .EXAMPLE
      Get-StitchConfigurationPath

      `.stitch`
    .EXAMPLE
      Get-StitchConfigurationPath | Select-Object -ExpandProperty System

      `C:\ProgramData\stitch`
    #>
  [CmdletBinding()]
  param(
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    $stitchConfig = Import-Configuration # this is from the Configuration module
    | Select-Object -ExpandProperty 'Configuration'
    if ($null -eq $stitchConfig) {
      Write-Verbose "Couldn't read stitch module configuration."
      $stitchConfig = @{
        System = "$env:ProgramData\stitch"
        User   = "$env:APPDATA\stitch"
        Local  = '.stitch'
      }
    }
  }
  process {
    $configInfo = [psobject]([string]$stitchConfig.Local)
    $configInfo | Add-Member -NotePropertyMembers $stitchConfig
    Write-Debug "`$configInfo is a $($configInfo.GetType().FullName)"
    $configInfo | Get-Member -MemberType NoteProperty
    | Foreach-Object {
        Write-Debug "it has $($_.Name) which is $($_.Definition)"
    }
    $configInfo

  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}
