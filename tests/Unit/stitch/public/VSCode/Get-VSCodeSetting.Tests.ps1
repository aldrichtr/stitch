

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

Describe "Testing public function Get-VSCodeSetting" -Tags @('unit', 'VSCodeSetting', 'Get' ) {
    Context 'The Get-VSCodeSetting command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Get-VSCodeSetting'
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
                $command.Parameters['Name'].Count | Should -Be 1
            }
        It "It Should have a 'Regex' parameter" {
                $command.Parameters['Regex'].Count | Should -Be 1
            }
    }
}

