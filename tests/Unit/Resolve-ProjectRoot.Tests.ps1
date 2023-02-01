BeforeDiscovery {
    if (-not($Global:StitchModuleLoaded)) {
        $thisFile = (Get-Item $PSCommandPath)

        $moduleLoaderFile = (Join-Path $thisFile.Directory 'loadModule.ps1')
        if (Test-Path $moduleLoaderFile) {
            . $moduleLoaderFile
        }
    }
}

Describe "Testing the public function Resolve-ProjectRoot"  -Tag @('unit', 'Resolve-ProjectRoot') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Resolve-ProjectRoot'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }
    Context 'When the directory is a subdirectory of the Project' {
        BeforeAll {
            $tDefaults = @{
                Source   = '.\source'
                Staging  = '.\stage'
                Tests    = '.\tests'
                Artifact = '.\out'
                Docs     = '.\docs'
            }
            $tProjectName = 'ProjectA'
            $tProjectPath = (New-Item -Path "TestDrive:\$tProjectName" -ItemType Directory)

            # set at least two so that `Test-ProjectRoot` will pass
            New-Item -Path (Join-Path $tProjectPath $tDefaults['Source']) -ItemType Directory -Force
            New-Item -Path (Join-Path $tProjectPath $tDefaults['Staging']) -ItemType Directory -Force
            New-Item -Path (Join-Path $tProjectPath $tDefaults['Docs']) -ItemType Directory -Force

            # create a nested directory structure so we can resolve "up"
            # since the default depth is 8, we need more than that to test for failure
            $currentDirectory = Get-Item (Join-Path $tProjectPath $tDefaults['Staging'])
            foreach ($level in 1..10) {
                $nestedPath       = (Join-Path $currentDirectory "Subdir$level" )
                $currentDirectory = (New-Item $nestedPath -ItemType Directory -Force)
                Set-Variable -Name "directoryLevel$level" -Value $currentDirectory
            }
        }

        It "Should return $tProjectPath" {
            Resolve-ProjectRoot -Path $directoryLevel4 | Should -Be $tProjectPath.FullName
        }

        It "Should throw an error when depth is gt 8" {
            {Resolve-ProjectRoot -Path $directoryLevel10} | Should -Throw "Could not find project root in 8 levels"
        }
    }
}
