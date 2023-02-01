BeforeDiscovery {
    if (-not($Global:StitchModuleLoaded)) {
        $thisFile = (Get-Item $PSCommandPath)

        $moduleLoaderFile = (Join-Path $thisFile.Directory 'loadModule.ps1')
        if (Test-Path $moduleLoaderFile) {
            . $moduleLoaderFile
        }
    }
}

Describe "Testing public function New-SourceTypeMap" -Tags @('unit', 'SourceTypeMap', 'New' ) {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command ' New-SourceTypeMap'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }
}

