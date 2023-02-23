
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

BeforeAll {
    # Convert the test file's name into the source file's name and then
    # dot-source the source file
    # This method requires `tests/` to be structured the same as `source/`

    $sourceFile = $PSCommandPath -replace '\.Tests\.ps1', '.ps1'
    $sourceFile = $sourceFile -replace 'tests' , 'source'
    if (Test-Path $sourceFile) {
        . $sourceFile
    } else {
        throw "Could not find $sourceFile from $PSCommandPath"
    }

    $testFileItem = Get-Item $PSCommandPath
    $currentDirectory = $testFileItem.Directory
    $commandName = $testFileItem.BaseName -replace '\.Tests', ''
    $dataDirectory = (Join-Path $currentDirectory "$commandName.Data")
}

Describe "Testing the public function Resolve-ProjectName"  -Tag @('unit', 'Resolve-ProjectName') {
    Context 'The Resolve-ProjectName command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Resolve-ProjectName'
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

    }

    Context 'When the build configuration contains the project name' {
        BeforeAll {
            function Get-BuildConfiguration {}

            Mock Get-BuildConfiguration {
                return @{
                    Project = @{
                        Name = 'MultiModuleProject'
                        Path = 'C:\Windows\Temp'
                    }
                }
            }
        }

        It 'Should return the name in the Project.Name field' {
            Resolve-ProjectName | Should -BeLike 'MultiModuleProject'
        }
    }
}
