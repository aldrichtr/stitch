

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

Describe "Testing private function Get-SourceItemInfo" -Tags @('unit', 'SourceItemInfo', 'Get' ) {
    Context 'The Get-SourceItemInfo command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Get-SourceItemInfo'
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
        It "It Should have a 'Root' parameter" {
                $command.Parameters['Root'].Count | Should -Be 1
            }
        It "It Should have a 'TypeMap' parameter" {
                $command.Parameters['TypeMap'].Count | Should -Be 1
            }
    }
}

