
<#
.SYNOPSIS
    Format the footer of the build output
#>

Set-BuildFooter {
    param($Path)
    Invoke-OutputHook 'SetBuildFooter' 'Before'

    if ($task.InvocationInfo.InvocationName -like 'phase') {
        logEnter "$('-' * 80)"
    }

    Invoke-OutputHook 'SetBuildFooter' 'After'
}
