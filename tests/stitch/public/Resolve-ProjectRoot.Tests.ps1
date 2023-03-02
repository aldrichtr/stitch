
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

Describe "Testing the public function Resolve-ProjectRoot"  -Tag @('unit', 'Resolve-ProjectRoot') {
    Context 'The Resolve-ProjectRoot command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Resolve-ProjectRoot'
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
        It "It Should have a 'Depth' parameter" {
            $command.Parameters['Depth'].Count | Should -Be 1
        }
        It "It Should have a 'Defaults' parameter" {
            $command.Parameters['Defaults'].Count | Should -Be 1
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
    Context 'When the directory is a subdirectory of the Project' {
        BeforeAll {

            # TODO: I'm not sure how to de-couple Test-ProjectRoot from Resolve-ProjectRoot
            $testProjectRootSource = $sourceFile -replace 'Resolve-', 'Test-'

            if (Test-Path $testProjectRootSource) {
                . $testProjectRootSource
            } else {
                throw "Could not import $testProjectRootSource"
            }

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
