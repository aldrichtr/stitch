BeforeDiscovery {
    if (-not($Global:StitchModuleLoaded)) {
        $thisFile = (Get-Item $PSCommandPath)

        $moduleLoaderFile = (Join-Path $thisFile.Directory 'loadModule.ps1')
        if (Test-Path $moduleLoaderFile) {
            . $moduleLoaderFile
        }
    }

}

Describe "Testing the public function Resolve-ProjectName"  -Tag @('unit', 'Resolve-ProjectName') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Resolve-ProjectName'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When the build configuration contains the project name' {
        BeforeAll {
            Mock Get-BuildConfiguration -ModuleName 'stitch' {
                return @{
                    Project = @{
                        Name = 'MultiModuleProject'
                        Path = 'C:\Windows\Temp'
                    }
                }
            }
        }

        It 'Should return the name in the Project.Name field' {
            Resolve-ProjectName | Should -BeLike 'MultiModuleProject'
        }
    }
}
