
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


Describe 'Testing the public function Test-ProjectRoot' -Tag @('unit', 'public') {
    Context 'The Test-ProjectRoot command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Test-ProjectRoot'
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
        It "It Should have a 'Defaults' parameter" {
            $command.Parameters['Defaults'].Count | Should -Be 1
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
    }
    Context 'When at least two of the default directories are present' {
        BeforeAll {
            $tDefaults = @{
                Source   = 'source'
                Staging  = 'stage'
                Tests    = 'tests'
                Artifact = 'out'
                Docs     = 'docs'
            }
            $tProjectName = 'ProjectA'
            $tProjectPath = (New-Item -Path (Join-Path $TestDrive $tProjectName) -ItemType Directory)
            function createDefaultPath {
                param(
                    [Parameter()]
                    [string]$Type
                )
                New-Item -Path (Join-Path $tProjectPath $tDefaults[$Type]) -ItemType Directory
            }
        }
        Context 'When <Description> are present' -ForEach @(
            @{ Description = 'Source'  ; Paths = 'Source'  ; ReturnValue = $false }
            @{ Description = 'Source and Staging'  ; Paths = 'Source', 'Staging'  ; ReturnValue = $true }
            @{ Description = 'Source and Tests'    ; Paths = 'Source', 'Tests'    ; ReturnValue = $true }
            @{ Description = 'Source and Artifact' ; Paths = 'Source', 'Artifact' ; ReturnValue = $true }
            @{ Description = 'Source and Docs'     ; Paths = 'Source', 'Docs'     ; ReturnValue = $true }
        ) {

            BeforeAll {
                foreach ($path in $Paths) {
                    createDefaultPath -Type $path
                }
            }

            It 'Should be <ReturnValue>' {
                $tProjectPath | Test-ProjectRoot | Should -Be $ReturnValue
            }
        }
    }
}
