

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

Describe "Testing private function Add-MarkdownElement" -Tags @('unit', 'MarkdownElement', 'Add' ) {
    Context 'The Add-MarkdownElement command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Add-MarkdownElement'
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

        It "It Should have a 'Element' parameter" {
                $command.Parameters['Element'].Count | Should -Be 1
            }
        It "It Should have a 'Document' parameter" {
                $command.Parameters['Document'].Count | Should -Be 1
            }
        It "It Should have a 'Index' parameter" {
                $command.Parameters['Index'].Count | Should -Be 1
            }
        It "It Should have a 'PassThru' parameter" {
                $command.Parameters['PassThru'].Count | Should -Be 1
            }
    }
}

