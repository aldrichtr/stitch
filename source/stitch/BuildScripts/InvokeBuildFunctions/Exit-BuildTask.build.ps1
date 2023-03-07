
Exit-BuildTask {
    #-------------------------------------------------------------------------------
    #region Before hook

        if ($null -ne $Output) {
        if ($Output.ContainsKey('ExitBuildTask')) {
            if ($Output.ExitBuildTask.ContainsKey('Before')) {
                if ($Output.ExitBuildTask.Before -is [scriptblock]) {
                    $Output.ExitBuildTask.Before.invoke()
                } elseif ($Output.ExitBuildTask.Before -is [string]) {
                    logEnter $Output.ExitBuildTask.Before
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
        if ($Output.ContainsKey('ExitBuildTask')) {
            if ($Output.ExitBuildTask.ContainsKey('After')) {
                if ($Output.ExitBuildTask.After -is [scriptblock]) {
                    $Output.ExitBuildTask.After.invoke()
                } elseif ($Output.ExitBuildTask.After -is [string]) {
                    logEnter $Output.ExitBuildTask.After
                }
            }
        }
    }

    #endregion After hook
    #-------------------------------------------------------------------------------
}
