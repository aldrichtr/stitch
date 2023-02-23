
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


Describe "Testing the public function Test-PathIsIn"  -Tag @('unit', 'Test-PathIsIn') {
    Context 'The Test-PathIsIn command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Test-PathIsIn'
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
            $command.Parameters['Path'].Attributes.Mandatory | Should -BeTrue
        }
        It "It Should have a 'Parent' parameter" {
            $command.Parameters['Parent'].Count | Should -Be 1
        }
        It "It Should have a 'CaseSensitive' parameter" {
            $command.Parameters['CaseSensitive'].Count | Should -Be 1
        }
    }

    Context 'When given path <Path> and parent <Parent>' -ForEach @(
        @{ Path = "TestDrive:\Windows\System32\TestDir"; Parent = "TestDrive:\Windows"; Result = $true }
        @{ Path = "TestDrive:\Windows\System32\TestDir"; Parent = "TestDrive:\Windows\System32"; Result = $true }
        @{ Path = "TestDrive:\Windows\System32\TestDir"; Parent = "TestDrive:\Windows\System"; Result = $false }
        @{ Path = "TestDrive:\Windows\System32\TestDir"; Parent = "TestDrive:\Windows\Another"; Result = $false }
    ){
        BeforeAll {
            $root = (Join-Path $TestDrive "Windows")
            "System", "System32", "Another", "System32/TestDir" | Foreach-Object {
                New-Item -Path (Join-Path $root $_ -ItemType Directory) -Force
            }
        }
        It 'Should return <Result>' {
            $Path | Test-PathIsIn $Parent | Should -Be $Result
        }
    }
}
