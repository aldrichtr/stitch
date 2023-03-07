
Exit-BuildJob {
    #-------------------------------------------------------------------------------
    #region Before hook

        if ($null -ne $Output) {
        if ($Output.ContainsKey('ExitBuildJob')) {
            if ($Output.ExitBuildJob.ContainsKey('Before')) {
                if ($Output.ExitBuildJob.Before -is [scriptblock]) {
                    $Output.ExitBuildJob.Before.invoke()
                } elseif ($Output.ExitBuildJob.Before -is [string]) {
                    logEnter $Output.ExitBuildJob.Before
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
        if ($Output.ContainsKey('ExitBuildJob')) {
            if ($Output.ExitBuildJob.ContainsKey('After')) {
                if ($Output.ExitBuildJob.After -is [scriptblock]) {
                    $Output.ExitBuildJob.After.invoke()
                } elseif ($Output.ExitBuildJob.After -is [string]) {
                    logEnter $Output.ExitBuildJob.After
                }
            }
        }
    }

    #endregion After hook
    #-------------------------------------------------------------------------------
}
