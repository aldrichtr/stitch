

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

Describe "Testing public function Test-PathIsIn" -Tags @('unit', 'PathIsIn', 'Test' ) {
    Context 'The Test-PathIsIn command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Test-PathIsIn'
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
                $command.Parameters['Path'].Attributes.Mandatory | Should -BeTrue
            }
        It "It Should have a 'Parent' parameter" {
                $command.Parameters['Parent'].Count | Should -Be 1
            }
        It "It Should have a 'CaseSensitive' parameter" {
                $command.Parameters['CaseSensitive'].Count | Should -Be 1
            }
    }
}

