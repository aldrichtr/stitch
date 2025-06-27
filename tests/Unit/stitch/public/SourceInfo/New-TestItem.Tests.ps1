

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

Describe "Testing public function New-TestItem" -Tags @('unit', 'TestItem', 'New' ) {
    Context 'The New-TestItem command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'New-TestItem'
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
        It "It Should have a 'Force' parameter" {
                $command.Parameters['Force'].Count | Should -Be 1
            }
        It "It Should have a 'PassThru' parameter" {
                $command.Parameters['PassThru'].Count | Should -Be 1
            }
    }
}

