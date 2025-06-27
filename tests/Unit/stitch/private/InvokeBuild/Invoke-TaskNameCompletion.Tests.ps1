

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
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

Describe 'Testing private function Invoke-TaskNameCompletion' -Tags @('unit', 'TaskNameCompletion', 'Invoke' ) {
    Context 'The Invoke-TaskNameCompletion command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Invoke-TaskNameCompletion'
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

        It "It Should have a 'commandName' parameter" {
            $command.Parameters['commandName'].Attributes | Should -BeTrue
        }
        It "It Should have a 'parameterName' parameter" {
            $command.Parameters['parameterName'].Attributes | Should -BeTrue
        }
        It "It Should have a 'wordToComplete' parameter" {
            $command.Parameters['wordToComplete'].Attributes | Should -BeTrue
        }
        It "It Should have a 'commandAst' parameter" {
            $command.Parameters['commandAst'].Attributes | Should -BeTrue
        }
        It "It Should have a 'fakeBoundParameters' parameter" {
            $command.Parameters['fakeBoundParameters'].Attributes | Should -BeTrue
        }
    }
}
