
function New-StitchState {
  <#
  .SYNOPSIS
    Instantiate a state object for maintaining variables required by stitch
  #>
  [CmdletBinding()]
  param(
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    $context = @{
      __MODULE_PATH__ = $self.Module.Path | Split-Path
    }
  }
  process {
    # TODO: What does this improve over the Import-Configuration function?
    $configurationFile = (Join-Path ($self.Module.Path | Split-Path) 'Configuration.psd1')
    Write-Debug "Attempting to load $configurationFile"

    $content = (Get-Content -Path $configurationFile -Raw)

    $context.GetEnumerator() |
      Foreach-Object {
        $content = $content -replace [regex]::Escape($_.Key), $_.Value
    }
    if ($configurationFile | Test-Path) {
      Write-Debug "- File path checks out.  Loading data"
      try {
        $sb = [scriptblock]::Create($content)
        $config = $sb.Invoke()
      } catch {
        $originalError = $_
        $message = "Could not create state object for stitch"
        $exceptionText = ( @($message, $originalError.ToString()) -join "`n")
        $thisException = [Exception]::new($exceptionText)
        $eRecord = [System.Management.Automation.ErrorRecord]::new(
          $thisException,
          $originalError.FullyQualifiedErrorId,
          $originalError.CategoryInfo.Category,
          $configurationFile
        )
        $PSCmdlet.ThrowTerminatingError( $eRecord )
      }
      Write-Debug "  - Success"
      $config
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
