<#
Use this file to manage the phases and tasks.
#>

'Build' | jobs @(
    'convert.codeblocks.pwsh',
    'format.common.params',
    'add.component.heading',
    'invoke.markdownlint'
)
