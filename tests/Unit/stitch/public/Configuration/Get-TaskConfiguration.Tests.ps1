

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

Describe "Testing public function Get-TaskConfiguration" -Tags @('unit', 'TaskConfiguration', 'Get' ) {
    Context 'The Get-TaskConfiguration command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Get-TaskConfiguration'
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

        It "It Should have a 'Task' parameter" {
                $command.Parameters['Task'].Count | Should -Be 1
            }
        It "It Should have a 'TaskConfigPath' parameter" {
                $command.Parameters['TaskConfigPath'].Count | Should -Be 1
            }
    }
}

