

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
param()

BeforeAll {
    $sourceFile = (Get-SourceFilePath $PSCommandPath)
    if (Test-Path $sourceFile) {
        Import-Module PowerGit
        . $sourceFile
    } else {
        throw "Could not find $sourceFile from $PSCommandPath"
    }

    $dataDirectory = (Get-TestDataPath $PSCommandPath)
}

Describe "Testing public function Add-GitFile" -Tags @('unit', 'GitFile', 'Add' ) {
    Context 'The Add-GitFile command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Add-GitFile'
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

        It "It Should have parameters" {
            $command.Parameters | Should -Not -BeNullOrEmpty
        }
        It "It Should have a 'Entry' parameter" {
                $command.Parameters['Entry'].Count | Should -Be 1 -Because "Parameters should be $($command.Parameters.Keys -join ', ')"
            }
        It "It Should have a 'Path' parameter" {
                $command.Parameters['Path'].Count | Should -Be 1
            }
        It "It Should have a 'All' parameter" {
                $command.Parameters['All'].Count | Should -Be 1
            }
        It "It Should have a 'RepoRoot' parameter" {
                $command.Parameters['RepoRoot'].Count | Should -Be 1
            }
        It "It Should have a 'PassThru' parameter" {
                $command.Parameters['PassThru'].Count | Should -Be 1
            }
    }
}
