

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

Describe "Testing public function Merge-BuildConfiguration" -Tags @('unit', 'BuildConfiguration', 'Merge' ) {
    Context 'The Merge-BuildConfiguration command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Merge-BuildConfiguration'
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
                $command.Parameters['Path'].Count | Should -Be 1
            }
        It "It Should have a 'Object' parameter" {
                $command.Parameters['Object'].Attributes.Mandatory | Should -BeTrue
            }
        It "It Should have a 'Key' parameter" {
                $command.Parameters['Key'].Count | Should -Be 1
            }
    }
}

