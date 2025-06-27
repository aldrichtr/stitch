

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

Describe "Testing public function New-FunctionItem" -Tags @('unit', 'FunctionItem', 'New' ) {
    Context 'The New-FunctionItem command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'New-FunctionItem'
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
        It "It Should have a 'Module' parameter" {
                $command.Parameters['Module'].Attributes.Mandatory | Should -BeTrue
            }
        It "It Should have a 'Visibility' parameter" {
                $command.Parameters['Visibility'].Count | Should -Be 1
            }
        It "It Should have a 'Begin' parameter" {
                $command.Parameters['Begin'].Count | Should -Be 1
            }
        It "It Should have a 'Process' parameter" {
                $command.Parameters['Process'].Count | Should -Be 1
            }
        It "It Should have a 'End' parameter" {
                $command.Parameters['End'].Count | Should -Be 1
            }
        It "It Should have a 'Component' parameter" {
                $command.Parameters['Component'].Count | Should -Be 1
            }
        It "It Should have a 'Force' parameter" {
                $command.Parameters['Force'].Count | Should -Be 1
            }
        It "It Should have a 'PassThru' parameter" {
                $command.Parameters['PassThru'].Count | Should -Be 1
            }
    }
}

