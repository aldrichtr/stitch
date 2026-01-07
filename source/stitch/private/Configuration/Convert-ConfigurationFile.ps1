
function Convert-ConfigurationFile {
  <#
    .SYNOPSIS
        Convert a configuration file into a powershell hashtable.  Can be psd1, yaml, or json
    #>
  [CmdletBinding()]
  param(
    # Specifies a path to one or more configuration files.
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
    $configOptions = @{}
  }
  process {
    Write-Debug "Getting ready to convert configuration file $Path"
    if (Test-Path $Path) {
      Write-Debug '  - File exists'
      if ($Path | Test-Path -PathType Container) {
        $configOptions = ( Get-ChildItem -Path $Path -Recurse |
            ForEach-Object {
              $configOptions = $configOptions | Update-Object (Convert-ConfigurationFile $_)
            })
      } else {
        $pathItem = Get-Item $Path
        switch -Regex ($pathItem.Extension) {
          '\.psd1' {
            #! Note we use the 'Unsafe' parameter so we can have scriptblocks and
            #! variables in our psd
            Write-Debug '  - Importing PSD'
            $configOptions = (Import-Psd -Path $pathItem -Unsafe)
          }
          '\.y(a)?ml' {
            Write-Debug '  - Importing YAML'
            $configOptions = (Get-Content $pathItem | ConvertFrom-Yaml -Ordered)
          }
          '\.json(c)?' {
            Write-Debug '  - Importing JSON'
            $configOptions = (Get-Content $pathItem | ConvertFrom-Json -Depth 16)
          }
          '\.toml' {
            Write-Debug '  - Importing TOML'
            $configOptions = (Get-Content $pathItem | ConvertFrom-Toml)
          }
          default {
            Write-Warning "Could not determine the type for $($pathItem.FullName)"
          }
        }
        if ($null -ne $configOptions) {
          $configOptions
        } else {
          Write-Debug 'conversion returned no data'
        }
      }
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
