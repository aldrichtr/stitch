
using namespace System.Collections

function Import-ProfileConfiguration {
  <#
  .EXTERNALHELP
    stitch-Help.xml
  #>
  [CmdletBinding()]
  param(
    # The name of the profile to import
    [Parameter(
      Position = 0,
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
    $state     = Get-StitchState
    $configDir = 'config'
    $buildDir  = 'build'
    $maxDepth  = 4

    $config = @{}
  }
  process {

    if (-not ($PSBoundParameters.ContainsKey('Name'))) { $Name = 'default' }

    if (-not ($PSBoundParameters.ContainsKey('Scope'))) { $Scope = [Scope]::Local }

    $root = Resolve-ScopeRoot $Scope

    if (-not ($root | Test-Path)) {
      throw "Resolved root directory for scope '$($scope.ToString())' as $root, but it does not exist"
    }

    $profilePath = Resolve-ProfilePath -Scope $Scope -Name $Name
    Write-Debug "- Looking for $configDir/$buildDir in $profilePath"

    $profileBuildConfigPath = ($profilePath | Join-Path $configDir $buildDir)

    $fileOptions = @{
      Path    = $profileBuildConfigPath
      Include = $state.FileTypes
      Recurse = $true
    }

    Write-Debug "Looking for files in $profileBuildConfigPath that match $($fileOptions.Include -join ', ')"
    $configFiles = Get-ChildItem @fileOptions
    foreach ($file in $configFiles) {
      try {
        $fileConfig = $file | Convert-ConfigurationFile
      } catch {
        throw "There was an error importing file $($file.Name)`n$_"
      }
      # NOTE: the file could be `config.psd1` in which case we just import that
      # without processing the filename.
      if ($file.BaseName -match '^config$') {
        $config = $config | Update-Object $fileConfig
      } else {
        $baseKey = ($file.BaseName -replace '\.config$', '')
        [ref]$config | Update-TableItem $fileConfig $baseKey
      }
    }
    $config
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
