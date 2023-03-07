
Exit-Build {
    if ($null -ne $Output) {
        if ($Output.ContainsKey('ExitBuild')) {
            if ($Output.ExitBuild.ContainsKey('Before')) {
                if ($Output.ExitBuild.Before -is [scriptblock]) {
                    $Output.ExitBuild.Before.invoke()
                } elseif ($Output.ExitBuild.Before -is [string]) {
                    logEnter $Output.ExitBuild.Before
                }
            }
        }
    }

    if (-not($SkipBuildHeader)) {
        $tasks = ${*}.Tasks
        $errors = ${*}.Errors
        $warnings = ${*}.Warnings
        logExit "$('#' * 80)"
        logExit '{0} tasks: {1} errors, {2} warnings' $tasks.Count, $errors.Count, $warnings.Count
        logExit 'Total Elapsed time: {0}' ([DateTime]::Now - ${*}.Started)
        logExit "$('#' * 80)"
    }
    if ($null -ne $Output) {
        if ($Output.ContainsKey('ExitBuild')) {
            if ($Output.ExitBuild.ContainsKey('After')) {
                if ($Output.ExitBuild.After -is [scriptblock]) {
                    $Output.ExitBuild.After.invoke()
                } elseif ($Output.ExitBuild.After -is [string]) {
                    logEnter $Output.ExitBuild.After
                }
            }
        }
    }
}
