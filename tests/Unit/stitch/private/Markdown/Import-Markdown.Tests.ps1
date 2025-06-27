

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

Describe "Testing private function Import-Markdown" -Tags @('unit', 'Markdown', 'Import' ) {
    Context 'The Import-Markdown command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Import-Markdown'
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
        It "It Should have a 'Extension' parameter" {
                $command.Parameters['Extension'].Count | Should -Be 1
            }
        It "It Should have a 'TrackTrivia' parameter" {
                $command.Parameters['TrackTrivia'].Count | Should -Be 1
            }
    }
}

