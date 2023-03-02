
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

Describe "Testing public function Get-SourceTypeMap" -Tags @('unit', 'SourceTypeMap', 'Get' ) {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Get-SourceTypeMap'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }
}
