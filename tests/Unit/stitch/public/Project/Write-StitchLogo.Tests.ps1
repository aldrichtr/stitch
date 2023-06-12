

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

Describe "Testing public function Write-StitchLogo" -Tags @('unit', 'StitchLogo', 'Write' ) {
    Context 'The Write-StitchLogo command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Write-StitchLogo'
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

        It "It Should have a 'Size' parameter" {
                $command.Parameters['Size'].Count | Should -Be 1
            }
        It "It Should have a 'NoColor' parameter" {
                $command.Parameters['NoColor'].Count | Should -Be 1
            }
    }
}

