

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

Describe "Testing public function Undo-GitCommit" -Tags @('unit', 'GitCommit', 'Undo' ) {
    Context 'The Undo-GitCommit command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Undo-GitCommit'
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

        It "It Should have a 'Hard' parameter" {
                $command.Parameters['Hard'].Count | Should -Be 1
            }
        It "It Should have a 'Soft' parameter" {
                $command.Parameters['Soft'].Count | Should -Be 1
            }
    }
}

