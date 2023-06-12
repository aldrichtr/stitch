BeforeAll {
    # This method requires `tests/` to be structured the same as `source/`
    $sourceFile = (Get-SourceFilePath $PSCommandPath)
    if (Test-Path $sourceFile) {
        # We don't need to source the build script, it is loaded by Invoke-Build
    } else {
        throw "Could not find $sourceFile from $PSCommandPath"
    }
}

Describe "Testing the public function Import-PhaseDefinition"  -Tag @('unit', 'Import-PhaseDefinition') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Import-PhaseDefinition'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }
}
