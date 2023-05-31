

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
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

Describe 'Testing public function Merge-SourceItem' -Tags @('unit', 'SourceItem', 'Merge' ) {
    Context 'The Merge-SourceItem command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Merge-SourceItem'
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

        It "It Should have a 'SourceItem' parameter" {
            $command.Parameters['SourceItem'].Count | Should -Be 1
        }
        It "It Should have a 'Path' parameter" {
            $command.Parameters['Path'].Count | Should -Be 1
        }
        It "It Should have a 'AsSection' parameter" {
            $command.Parameters['AsSection'].Count | Should -Be 1
        }
    }
}
