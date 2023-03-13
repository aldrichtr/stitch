<#
.SYNOPSIS
    This function is called at the start of a task **scriptblock**
.NOTES
    The $Job variable is the ScriptBlock object
#>

Enter-BuildJob {
    #-------------------------------------------------------------------------------
    #region Before hook

        if ($null -ne $Output) {
        if ($Output.ContainsKey('EnterBuildJob')) {
            if ($Output.EnterBuildJob.ContainsKey('Before')) {
                if ($Output.EnterBuildJob.Before -is [scriptblock]) {
                    $Output.EnterBuildJob.Before.invoke()
                } elseif ($Output.EnterBuildJob.Before -is [string]) {
                    logEnter $Output.EnterBuildJob.Before
                }
            }
        }
    }

    #endregion Before hook
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Stitch code

    #endregion Stitch code
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region After hook
    if ($null -ne $Output) {
        if ($Output.ContainsKey('EnterBuildJob')) {
            if ($Output.EnterBuildJob.ContainsKey('After')) {
                if ($Output.EnterBuildJob.After -is [scriptblock]) {
                    $Output.EnterBuildJob.After.invoke()
                } elseif ($Output.EnterBuildJob.After -is [string]) {
                    logEnter $Output.EnterBuildJob.After
                }
            }
        }
    }

    #endregion After hook
    #-------------------------------------------------------------------------------
}
