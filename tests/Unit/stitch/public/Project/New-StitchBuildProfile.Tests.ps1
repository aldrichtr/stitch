

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

Describe "Testing public function New-StitchBuildProfile" -Tags @('unit', 'StitchBuildProfile', 'New' ) {
    Context 'The New-StitchBuildProfile command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'New-StitchBuildProfile'
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
        It "It Should have a 'ProfileRoot' parameter" {
                $command.Parameters['ProfileRoot'].Count | Should -Be 1
            }
        It "It Should have a 'Force' parameter" {
                $command.Parameters['Force'].Count | Should -Be 1
            }
    }
}

