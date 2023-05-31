
BeforeDiscovery {
    $moduleName = 'stitch'
    $module = Get-Module $moduleName -ErrorAction SilentlyContinue
    if ($null -ne $module) {
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
    $options = @{
        Name = "$moduleName markdown help content"
        Tag  = @( 'analyze','module','docs', 'markdown', 'help')
    }
}

Describe @options {
    Context 'When getting markdown help for function <Command>' -ForEach $commandList {
        BeforeAll {
            $markdownFile = "$BuildRoot\docs\$moduleName.md"
        }

        It "<Command> should have a markdown help file" {
            $markdownFile | Should -Exist
        }
    }
}
