

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

Describe "Testing public function Initialize-StitchProject" -Tags @('unit', 'StitchProject', 'Initialize' ) {
    Context 'The Initialize-StitchProject command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Initialize-StitchProject'
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

        It "It Should have a 'Destination' parameter" {
                $command.Parameters['Destination'].Count | Should -Be 1
            }
        It "It Should have a 'Force' parameter" {
                $command.Parameters['Force'].Count | Should -Be 1
            }
        It "It Should have a 'Quiet' parameter" {
                $command.Parameters['Quiet'].Count | Should -Be 1
            }
    }
}

