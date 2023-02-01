BeforeDiscovery {
    if (-not($Global:StitchModuleLoaded)) {
        $thisFile = (Get-Item $PSCommandPath)

        $moduleLoaderFile = (Join-Path $thisFile.Directory 'loadModule.ps1')
        if (Test-Path $moduleLoaderFile) {
            . $moduleLoaderFile
        }
    }
}


Describe 'Testing the public function Get-BuildConfiguration' -Tag @('unit', 'public') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Get-BuildConfiguration'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }
    Context 'When the command is run inside a valid project' {
        BeforeAll {
            $root = New-Item -Path "TestDrive:\MultiModuleProject" -ItemType Directory
            #! the $Tests variable is provided by the build script.  If this test is run
            #! outside the build script, $Tests would need to be set correctly first
            Copy-Item "$Tests\data\MultiModuleProject\*" -Destination $root.FullName -Recurse
            Set-Location $root
            $null = & {git init 2>&1}
            $null = & {git add . 2>&1}
            $null = & {git commit -m"Initial project import" 2>&1}
            $testInfo = Get-BuildConfiguration
        }

        It "Should have a git repository" {
            Get-Item (Join-Path $root '.\.git\config') | Should -FileContentMatch '[core]'
        }

        It "Should have a Project Name of 'MultiModuleProject" {
            $testInfo.Project.Name | Should -BeLike 'MultiModuleProject'
        }

        It "Should have three modules in the project" {
            $testInfo.Modules.Keys.Count | Should -BeExactly 3
        }

        It "Should set the Parent module to 'RootModule' for 'Module1'" {
            $testInfo.Modules.Module1.Parent | Should -BeLike 'RootModule'
        }
    }
}
