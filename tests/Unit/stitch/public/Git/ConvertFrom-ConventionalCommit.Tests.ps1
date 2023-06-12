

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
param()

BeforeAll {
    $sourceFile = (Get-SourceFilePath $PSCommandPath)
    if (Test-Path $sourceFile) {
        . $sourceFile
    } else {
        throw "Could not find $sourceFile from $PSCommandPath"
    }

    $dataDirectory = (Get-TestDataPath $PSCommandPath)
}

Describe "Testing public function ConvertFrom-ConventionalCommit" -Tags @('unit', 'ConventionalCommit', 'ConvertFrom' ) {
    Context 'The ConvertFrom-ConventionalCommit command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'ConvertFrom-ConventionalCommit'
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

        It "It Should have a 'Message' parameter" {
                $command.Parameters['Message'].Count | Should -Be 1
            }
        It "It Should have a 'Sha' parameter" {
                $command.Parameters['Sha'].Count | Should -Be 1
            }
        It "It Should have a 'Author' parameter" {
                $command.Parameters['Author'].Count | Should -Be 1
            }
        It "It Should have a 'Committer' parameter" {
                $command.Parameters['Committer'].Count | Should -Be 1
            }
    }
}

