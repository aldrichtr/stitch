

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

Describe "Testing public function Join-PullRequest" -Tags @('unit', 'PullRequest', 'Join' ) {
    Context 'The Join-PullRequest command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Join-PullRequest'
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

        It "It Should have a 'RepositoryName' parameter" {
                $command.Parameters['RepositoryName'].Count | Should -Be 1
            }
        It "It Should have a 'DontDelete' parameter" {
                $command.Parameters['DontDelete'].Count | Should -Be 1
            }
        It "It Should have a 'DefaultBranch' parameter" {
                $command.Parameters['DefaultBranch'].Count | Should -Be 1
            }
    }
}

