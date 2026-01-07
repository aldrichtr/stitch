using namespace System.Management.Automation.Language

BeforeDiscovery {
  $testsItem = Get-Item $PSCommandPath
  $dataDirectory = (Join-Path $testsItem.Directory "$($testsItem.BaseName).data")
}

$options = @{
    Tag  = @( 'unit', 'Configuration', 'Convert', 'ConfigurationFile')
    Name = 'SCENARIO The function Convert-ConfigurationFile is tested for functionality within the module'
    Foreach = $dataDirectory
}
Describe @options {
  BeforeAll {
    $TestData = $_
    $ConfigurationFiles = Get-ChildItem $TestData
  }
    <# --=-- #>
    Context 'GIVEN the configuration file <_.Name>' -ForEach $ConfigurationFiles {
      BeforeAll {
        $TestDataFile = $_
        $result = $TestDataFile | Convert-ConfigurationFile -ErrorAction SilentlyContinue
      }
      It 'Then it should convert the content to an object' {
        $result | Should -Not -BeNullOrEmpty
      }

    }
    <# --=-- #>
}
