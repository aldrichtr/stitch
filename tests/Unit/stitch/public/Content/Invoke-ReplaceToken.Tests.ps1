

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

Describe "Testing public function Invoke-ReplaceToken" -Tags @('unit', 'ReplaceToken', 'Invoke' ) {
    Context 'The Invoke-ReplaceToken command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Invoke-ReplaceToken'
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

        It "It Should have a 'In' parameter" {
                $command.Parameters['In'].Attributes.Mandatory | Should -BeTrue
            }
        It "It Should have a 'Token' parameter" {
                $command.Parameters['Token'].Attributes.Mandatory | Should -BeTrue
            }
        It "It Should have a 'With' parameter" {
                $command.Parameters['With'].Attributes.Mandatory | Should -BeTrue
            }
        It "It Should have a 'Destination' parameter" {
                $command.Parameters['Destination'].Count | Should -Be 1
            }
    }
}

