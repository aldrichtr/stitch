@{
    # The relative path from the current workspace to the root directory of the module.
    MainModuleDirectory = '.\source\stitch'

    # The relative path from the current workspace to the main module manifest file.
     SourceManifestPath = '.\source\stitch\stitch.psd1'

    # The relative path from the current workspace to the string localization psd1 file.
    # StringLocalizationManifest = '.\module\en-US\Strings.psd1'

    # The relative path from the current workspace to the directory where markdown files are stored.
    MarkdownDocsPath = '.\docs\stitch'

    # The relative path(s) from the current workspace to the directory(ies) where functions are stored.
    FunctionPaths = '.\source\stitch\public', '.\source\stitch\private'

    # The string used to created line breaks. Defaults to "[Environment]::NewLine"
    # NewLine = [Environment]::NewLine

    # The string used to created indents. Defaults to four spaces.
    # TabString = '    '

    # Specifies whether namespaces will automatically be removed when writing type literal
    # expressions. Removed namespaces will be automatically added as a using statement.
    # EnableAutomaticNamespaceRemoval = $true

    CommandSplatRefactor = @{
        # The variable name to use when creating the splat expression variable. The default behavior
        # is to name the string similar to "getCommandNameHereSplat". Setting this to $null will
        # enforce the default behavior.
        VariableName = 'options'

        # Specifies whether a new line should be placed between the hashtable and the original command
        # expression.
        # NoNewLineAfterHashtable = $false

        # Specifies if additional parameters that have not been should be added to the splat
        # expression. The following options are available:
        #     'None' - Only bound parameters. This is the default.
        #     'Mandatory' - Mandatory parameters that have not yet been bound will be added.
        #     'All' - All resolved parameters will be added.
        # AdditionalParameters = 'None'

        # Specifies whether the value for additional unbound parameters should be a variable of the
        # same name as the parameter, or if it should be decorated with mandatoriness and parameter
        # type.
        #     $true - Path = $path
        #     $false - Path = $mandatoryStringPath
        # ExcludeHints = $false

        # Specifies the case style to use for generated variable names.
        #     'CamelCase' - $getChildItemSplat. This is the default.
        #     'PascalCase' - $GetChildItemSplat
        VariableCaseType = 'CamelCase'
    }

    ExpandMemberExpression = @{
        # Specifies whether non-public members should be included in the list of resolved members. If
        # a non-public member is selected, an expression utilizing reflection will be generated to
        # access the member.
        # AllowNonPublicMembers = $false
    }

    UsingStatements = @{
        # Specifies whether groups of using statement types should be separated with a new line character.
        SeparateGroupsWithNewLine = $false

        # Specifies whether using statements that start with "System" should be ordered first
        # regardless of alphabetical order.
        SystemNamespaceFirst = $true

        # The order in which groups of using statement types will appear.
        # UsingKindOrder = 'Assembly', 'Module', 'Namespace'
    }
}
