BeforeAll {
    # This method requires `tests/` to be structured the same as `source/`
    $sourceFile = "$BuildRoot\.build\profiles\docs\tasks\invoke.markdownlint.build.ps1"
    if (Test-Path $sourceFile) {
        . $sourceFile
    } else {
        throw "Could not find $sourceFile"
    }
}

Describe "Testing the Invoke-Build task invoke.markdownlint.build"  -Tag @('unit', 'task', 'invoke.markdownlint.build') {
    Context 'The command is available from the module' {
        BeforeAll {
            function Invoke-MockBuildTask {
                <#
                .SYNOPSIS
                    This function mocks Invoke-Build calling the specified task
                #>
                [CmdletBinding()]
                param(
                    [string]$Name,
                    [scriptblock]$Task
                )
                $functions = @{}
                $variables = [System.Collections.Generic.List[psvariable]]@()
                $arguments = @()

                $Task.InvokeWithContext($functions, $variables, $arguments)
            }

            function Write-BuildLog {}
            function Write-MockBuildLog {
                param(
                    [string]$Message
                )
            }
            Mock Write-BuildLog -MockWith Write-MockBuildLog
            Set-Alias task Invoke-MockBuildTask
            Set-Alias logDebug Write-MockBuildLog
            Set-Alias logInfo Write-MockBuildLog
            Set-Alias logWarn Write-MockBuildLog
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }

        AfterAll {
            Remove-Alias task, logDebug , logInfo, logWarn
        }
    }
}
