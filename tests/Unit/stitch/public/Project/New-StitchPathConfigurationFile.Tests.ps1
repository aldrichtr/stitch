

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

Describe "Testing public function New-StitchPathConfigurationFile" -Tags @('unit', 'StitchPathConfigurationFile', 'New' ) {
    Context 'The New-StitchPathConfigurationFile command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'New-StitchPathConfigurationFile'
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

        It "It Should have a 'Source' parameter" {
                $command.Parameters['Source'].Count | Should -Be 1
            }
        It "It Should have a 'Tests' parameter" {
                $command.Parameters['Tests'].Count | Should -Be 1
            }
        It "It Should have a 'Staging' parameter" {
                $command.Parameters['Staging'].Count | Should -Be 1
            }
        It "It Should have a 'Artifact' parameter" {
                $command.Parameters['Artifact'].Count | Should -Be 1
            }
        It "It Should have a 'Docs' parameter" {
                $command.Parameters['Docs'].Count | Should -Be 1
            }
        It "It Should have a 'DontValidate' parameter" {
                $command.Parameters['DontValidate'].Count | Should -Be 1
            }
        It "It Should have a 'Force' parameter" {
                $command.Parameters['Force'].Count | Should -Be 1
            }
    }
}

