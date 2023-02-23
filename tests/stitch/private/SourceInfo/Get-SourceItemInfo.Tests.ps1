
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

Describe 'Testing private function Get-SourceItemInfo' -Tags @('unit', 'SourceItemInfo', 'Get' ) {
    Context 'The Get-SourceItemInfo command is available and is valid' {
        BeforeAll {
            $command = Get-Command 'Get-SourceItemInfo'
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
        It "It Should have a 'Root' parameter" {
            $command.Parameters['Root'].Count | Should -Be 1
        }
    }
    Context 'Given a source file In <Name>' -ForEach @(
        @{
            Name       = 'FunctionNoComponent'
            Path       = 'ModuleA\public\Get-FakeFunction.ps1'
            Visibility = 'public'
            Type = 'function'
            Verb = 'Get'
            Noun = 'FakeFunction'
        }
    ) {
        BeforeAll {

            function Get-SourceTypeMap {}

            Mock Get-SourceTypeMap {
                return @{
                    'public'     = @{ Visibility = 'public'; Type = 'function' }
                    'class'      = @{ Visibility = 'private'; Type = 'class' }
                    'classes'    = @{ Visibility = 'private'; Type = 'class' }
                    'enum'       = @{ Visibility = 'private'; Type = 'enum' }
                    'private'    = @{ Visibility = 'private'; Type = 'function' }
                    'resource'   = @{ Visibility = 'private'; Type = 'resource' }
                    'assembly'   = @{ Visibility = 'private'; Type = 'resource' }
                    'assemblies' = @{ Visibility = 'private'; Type = 'resource' }
                    'data'       = @{ Visibility = 'private'; Type = 'resource' }
                }
            }

            Copy-Item -Path (Join-Path $dataDirectory $Name) -Destination $TestDrive -Recurse
            $root = (Join-Path $TestDrive $Name)
            $sourceRoot = (Join-Path $root 'source')
            $sourceItemInfoOptions = @{
                Root = $sourceRoot
                Path = (Join-Path $sourceRoot $Path)
            }
            $sourceItem = Get-SourceItemInfo @sourceItemInfoOptions
        }

        It "The visibility should be <Visibility>" {
            $sourceItem.Visibility | Should -Be $Visibility
        }

        It "The Type should be <Type>" {
            $sourceItem.Type | Should -Be $Type
        }
        It "The verb should be <Verb>" {
            $sourceItem.Verb | Should -Be $Verb
        }
        It "The noun should be <Noun>" {
            $sourceItem.Noun | Should -Be $Noun
        }
    }
}
