$Script:Workspace = $psEditor.Workspace.Path
$Script:Source    = (Join-Path $Script:Workspace 'source') | Get-Item
$Script:Tests     = (Join-Path $Script:Workspace 'tests') | Get-Item
$Script:Docs      = (Join-Path $Script:Workspace 'docs') | Get-Item
$Script:Stage     = (Join-Path $Script:Workspace 'stage') | Get-Item
$Script:Artifact  = (Join-Path $Script:Workspace 'out') | Get-Item
$Script:Publish   = (Join-Path $Script:Workspace 'publish') | Get-Item


function New-TestDataDirectory {
  <#
  .SYNOPSIS
    Create the `Data Directory` for the given test case file
  #>
  [CmdletBinding()]
  param (
    # Specifies a path to one or more locations.
    [Parameter(
      Position = 0,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [Alias('PSPath')]
    [string[]]$Path
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    if (-not ($PSBoundParameters.ContainsKey('Path'))) {
      if ($null -ne $psEditor) {
        $Path = $psEditor.GetEditorContext().CurrentFile.Path
      }
    }

    if ($Path | Test-Path) {
      $item = Get-Item $Path
      $dirName = $item.BaseName -replace 'Tests$', 'Data'
      $dataDirectory = (Join-Path $item.Directory $dirName)
      if (-not ($dataDirectory | Test-Path)) {
        try {
          New-Item -Path $dataDirectory -ItemType Directory
        } catch {
          $err = $_
          $message = "Could not create data directory for $Path"
          $exceptionText = ( @($message, $err.ToString()) -join "`n")
          $thisException = [Exception]::new($exceptionText)
          $eRecord = [System.Management.Automation.ErrorRecord]::new(
            $thisException,
            $err.FullyQualifiedErrorId,
            $err.CategoryInfo.Category,
            $dataDirectory
          )
          $PSCmdlet.ThrowTerminatingError( $eRecord )
        }
      }
    } else {
      Write-Error "$Path is not a valid Path"
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}



function Switch-WorkspaceFile {
  <#
  .SYNOPSIS
    Switch between Source and Test file
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
    [string[]]$Path
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    if (-not ($PSBoundParameters.ContainsKey('Path'))) {
      if ($null -ne $psEditor) {
        $Path = $psEditor.GetEditorContext().CurrentFile.Path
      } else {
        throw 'No path given'
      }
    }

    if ($Path | Test-Path) {
      $item = Get-Item $Path
      if ($item.BaseName -match '\.Tests$') {
        $newPath = $Path -replace [regex]::Escape($Script:Tests.FullName), $Script:Source.FullName
        $newPath = $newPath -replace '\.Tests\.ps1$', '.ps1'
      } elseif ($item.FullName -match [regex]::Escape($Script:Source.FullName)) {
        $newPath = $Path -replace [regex]::Escape($Script:Source.FullName), $Script:Tests.FullName
        $newPath = $newPath -replace '\.ps1$', '.Tests.ps1'
      }
      if ($newPath | Test-Path) {
        Open-EditorFile $newPath
      } else {
        New-EditorFile $newPath
      }
    }

  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
