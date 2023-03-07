
<#
.SYNOPSIS
    Format the footer of the build output
#>

Set-BuildFooter {
    #-------------------------------------------------------------------------------
    #region Before hook

    if ($null -ne $Output) {
        if ($Output.ContainsKey('SetBuildFooter')) {
            if ($Output.SetBuildFooter.ContainsKey('Before')) {
                if ($Output.SetBuildFooter.Before -is [scriptblock]) {
                    $Output.SetBuildFooter.Before.invoke()
                } elseif ($Output.SetBuildFooter.Before -is [string]) {
                    logEnter $Output.SetBuildFooter.Before
                }
            }
        }
    }

    #endregion Before hook
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Stitch code

    if ($task.InvocationInfo.InvocationName -like 'phase') {
        logEnter "$('-' * 80)"
    }

    #endregion Stitch code
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region After hook
    if ($null -ne $Output) {
        if ($Output.ContainsKey('SetBuildFooter')) {
            if ($Output.SetBuildFooter.ContainsKey('After')) {
                if ($Output.SetBuildFooter.After -is [scriptblock]) {
                    $Output.SetBuildFooter.After.invoke()
                } elseif ($Output.SetBuildFooter.After -is [string]) {
                    logEnter $Output.SetBuildFooter.After
                }
            }
        }
    }

    #endregion After hook
    #-------------------------------------------------------------------------------
}
