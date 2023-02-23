
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

BeforeAll {
    # Convert the test file's name into the source file's name and then
    # dot-source the source file
    # This method requires `tests/` to be structured the same as `source/`

    $sourceFile = $PSCommandPath -replace '\.Tests\.ps1', '.ps1'
    $sourceFile = $sourceFile -replace 'tests' , 'source'
    if (Test-Path $sourceFile) {
        . $sourceFile
    } else {
        throw "Could not find $sourceFile from $PSCommandPath"
    }

    $testFileItem = Get-Item $PSCommandPath
    $currentDirectory = $testFileItem.Directory
    $commandName = $testFileItem.BaseName -replace '\.Tests', ''
    $dataDirectory = (Join-Path $currentDirectory "$commandName.Data")
}



Describe 'Testing the public function Get-BuildConfiguration' -Tag @('unit', 'public') {
    Context 'The Get-BuildConfiguration command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Get-BuildConfiguration'
            $tokens, $errors = @()
            $parsed = [System.Management.Automation.Language.Parser]::ParseFile($sourceFile, [ref]$tokens, [ref]$errors)

        }

        It 'The source file should exist' {
            $sourceFile | Should -Exist
        }

        It 'It should be a valid command' {
            $command | Should -Not -BeNullOrEmpty
        }

        It 'Should parse without error' {
            $errors.count | Should -Be 0
        }

        It "It Should have a 'Path' parameter" {
            $command.Parameters['Path'].Count | Should -Be 1
        }
        It "It Should have a 'ConfigurationFiles' parameter" {
            $command.Parameters['ConfigurationFiles'].Count | Should -Be 1
        }
        It "It Should have a 'Source' parameter" {
            $command.Parameters['Source'].Count | Should -Be 1
        }
        It "It Should have a 'Tests' parameter" {
            $command.Parameters['Tests'].Count | Should -Be 1
        }
        It "It Should have a 'Staging' parameter" {
            $command.Parameters['Staging'].Count | Should -Be 1
        }
        It "It Should have a 'Artifact' parameter" {
            $command.Parameters['Artifact'].Count | Should -Be 1
        }
        It "It Should have a 'Docs' parameter" {
            $command.Parameters['Docs'].Count | Should -Be 1
        }
    }
    Context 'When the command is run inside a valid project' {
        BeforeAll {
            $root = New-Item -Path "TestDrive:\MultiModuleProject" -ItemType Directory

            function Resolve-ProjectRoot {}

            function Get-ModuleItem {}

            Mock Resolve-ProjectRoot {
                return $root
            }

            Mock Get-ModuleItem {
                $modules = @{}
                Get-ChildItem (Join-Path $root 'source') -Directory {
                    $modules[$_.Name] = @{}
                }
                $modules
            } -ParameterFilter { $Path -like (Join-Path $root 'source') }

            Copy-Item "$dataDirectory\MultiModuleProject\*" -Destination $root.FullName -Recurse
            $location = Get-Location
            Set-Location $root
            $null = & {git init 2>&1}
            $null = & {git add . 2>&1}
            $null = & {git commit -m"Initial project import" 2>&1}
            Set-Location $location
            $testInfo = Get-BuildConfiguration -Path $root
        }

        It "Should have a git repository" {
            Get-Item (Join-Path $root '.\.git\config') | Should -FileContentMatch '[core]'
        }

        It "Should have a Project Name of 'MultiModuleProject'" {
            $testInfo.Project.Name | Should -BeLike 'MultiModuleProject'
        }

        It "Should have a Project Path of '$root'" {
            $testInfo.Project.Path | Should -BeLike $root
        }

        It "Should have a 'Modules' key" {
            $testInfo.Keys | Should -Contain 'Modules'
        }
    }
}
