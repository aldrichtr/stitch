BeforeDiscovery {
    if (-not($Global:StitchModuleLoaded)) {
        $thisFile = (Get-Item $PSCommandPath)

        $moduleLoaderFile = (Join-Path $thisFile.Directory 'loadModule.ps1')
        if (Test-Path $moduleLoaderFile) {
            . $moduleLoaderFile
        }
    }

}

Describe "Testing the public function Test-PathIsIn"  -Tag @('unit', 'Test-PathIsIn') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Test-PathIsIn'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When given path <Path> and parent <Parent>' -ForEach @(
        @{ Path = 'C:\Windows\System32\1043'; Parent = 'C:\Windows'; Result = $true }
        @{ Path = 'C:\Windows\System32\1043'; Parent = 'C:\Windows\System32'; Result = $true }
        @{ Path = 'C:\Windows\System32\1043'; Parent = 'C:\Windows\System'; Result = $false }
        @{ Path = 'C:\Windows\System32\1043'; Parent = 'C:\Windows\assembly'; Result = $false }
    ){
        It 'Should return <Result>' {
            $Path | Test-PathIsIn $Parent | Should -Be $Result
        }
    }
}
