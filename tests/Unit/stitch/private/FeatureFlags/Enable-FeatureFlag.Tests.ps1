

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

Describe "Testing private function Enable-FeatureFlag" -Tags @('unit', 'FeatureFlag', 'Enable' ) {
    Context 'The Enable-FeatureFlag command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Enable-FeatureFlag'
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

        It "It Should have a 'Name' parameter" {
                $command.Parameters['Name'].Attributes.Mandatory | Should -BeTrue
            }
        It "It Should have a 'Description' parameter" {
                $command.Parameters['Description'].Count | Should -Be 1
            }
    }
}

