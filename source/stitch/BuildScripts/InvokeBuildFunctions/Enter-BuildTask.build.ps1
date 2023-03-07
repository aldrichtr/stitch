
Enter-BuildTask {
    #-------------------------------------------------------------------------------
    #region Before hook

        if ($null -ne $Output) {
        if ($Output.ContainsKey('EnterBuildTask')) {
            if ($Output.EnterBuildTask.ContainsKey('Before')) {
                if ($Output.EnterBuildTask.Before -is [scriptblock]) {
                    $Output.EnterBuildTask.Before.invoke()
                } elseif ($Output.EnterBuildTask.Before -is [string]) {
                    logEnter $Output.EnterBuildTask.Before
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
        if ($Output.ContainsKey('EnterBuildTask')) {
            if ($Output.EnterBuildTask.ContainsKey('After')) {
                if ($Output.EnterBuildTask.After -is [scriptblock]) {
                    $Output.EnterBuildTask.After.invoke()
                } elseif ($Output.EnterBuildTask.After -is [string]) {
                    logEnter $Output.EnterBuildTask.After
                }
            }
        }
    }

    #endregion After hook
    #-------------------------------------------------------------------------------
}
