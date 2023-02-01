BeforeDiscovery {
    if (-not($Global:StitchModuleLoaded)) {
        $thisFile = (Get-Item $PSCommandPath)

        $moduleLoaderFile = (Join-Path $thisFile.Directory 'loadModule.ps1')
        if (Test-Path $moduleLoaderFile) {
            . $moduleLoaderFile
        }
    }
}

Describe "Testing the public function Get-ModuleItem"  -Tag @('unit', 'Get-ModuleItem') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Get-ModuleItem'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }
}
