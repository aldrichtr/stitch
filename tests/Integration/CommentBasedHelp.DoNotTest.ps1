
BeforeDiscovery {
    $ModuleName = 'stitch'
    $Module = Get-Module $ModuleName -ErrorAction SilentlyContinue
    if ($null -ne $Module ) {
        $commandList = [System.Collections.ArrayList]@()
        foreach ($command in  @(
            $Module.ExportedFunctions.Keys
            $Module.ExportedCmdlets.Keys
        )) {
            $commandList.Add( @{ Command = $command })
        }
    } else {
        throw "$ModuleName module was not loaded"
    }

    $Options = @{
        Name = "$ModuleName Help Content"
        Tags = @(
            'analyze',
            'module',
            'docs',
            'help'
        )
    }
}

Describe @Options {
    Context 'When getting help for function <Command>' -ForEach @(
        $commandList
    ) {
        BeforeAll {
            $ShouldProcessParameters = 'WhatIf', 'Confirm'
            $Help = Get-Help -Name $Command -Full | Select-Object -Property *
            $Parameters = Get-Help -Name $Command -Parameter * -ErrorAction Ignore |
                Where-Object {
                    (($null -ne $_.Name) -and
                     ($_.Name -notin $ShouldProcessParameters))
                 } |  ForEach-Object {
                        @{
                            Name        = $_.name
                            Description = $_.Description.Text
                        }
                    }
            $Ast = @{
                # Ast will be $null if the command is a compiled cmdlet
                Ast        = (Get-Content -Path "function:/$Command" -ErrorAction Ignore).Ast
                Parameters = $Parameters
            }
            $Examples = $Help.Help.Examples.Example | ForEach-Object { @{ Example = $_ } }
        }

        It 'has help content for <Command>' {
            $Help | Should -Not -BeNullOrEmpty
        }

        It 'contains a synopsis for <Command>' {
            $Help.Synopsis | Should -Not -BeNullOrEmpty
        }

        It 'contains a description for <Command>' {
            $Help.Description | Should -Not -BeNullOrEmpty
        }

        It 'has a help entry for all parameters of <Command>' -Skip:(-not ($Parameters -and $Ast.Ast)) {
            @($Parameters).Count | Should -Be $Ast.Body.ParamBlock.Parameters.Count -Because 'the number of parameters in the help should match the number in the function script'
        }

        It "has a description for <Command> parameter $Name" -Skip:(-not $Parameters) {
            $Description | Should -Not -BeNullOrEmpty -Because "parameter $Name should have a description"
        }

        It 'has at least one usage example for <Command>' {
            $Help.Examples.Example.Code.Count | Should -BeGreaterOrEqual 1
        }

        It "lists a description for <Command> example: `$Title" {
            $Example.Remarks | Should -Not -BeNullOrEmpty -Because "example $($Example.Title) should have a description!"
        }
    }
}
