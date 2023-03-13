<#
.SYNOPSIS
    Runs at the start of the build
#>


Enter-Build {
    #-------------------------------------------------------------------------------
    #region Before hook

    Write-Debug "`n$('-' * 80)`n-- Begin Enter-Build`n$('-' * 80)"
    if ($null -ne $Output) {
        if ($Output.ContainsKey('EnterBuild')) {
            if ($Output.EnterBuild.ContainsKey('Before')) {
                if ($Output.EnterBuild.Before -is [scriptblock]) {
                    $Output.EnterBuild.Before.invoke()
                } elseif ($Output.EnterBuild.Before -is [string]) {
                    logEnter $Output.EnterBuild.Before
                }
            }
        }
    }
    #endregion Before hook
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Stitch code

    $logoColor = $PSStyle.Foreground.FromRgb('#AA6600')
    $logoReset = $PSStyle.Reset
    if (-not($SkipLogo)) {
        "$logoColor$stitchLogoLarge$logoReset"
    }
    if ((-not($SkipBuildHeader)) -or
    ($null -ne $WhatIf)) {
        logEnter "$('#' * 80)"
        logEnter "# `u{E7A2} stitch (version $($stitchModule.Version))"
        logEnter "# loaded from $(Resolve-Path $stitchModule.Path -Relative)"
        logEnter "$('#' * 80)"
    }

    $BuildInfo = Get-BuildConfiguration
    Remove-Variable logoColor, logoReset

    #endregion Stitch code
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Before hook

    if ($null -ne $Output) {
        if ($Output.ContainsKey('EnterBuild')) {
            if ($Output.EnterBuild.ContainsKey('After')) {
                if ($Output.EnterBuild.After -is [scriptblock]) {
                    $Output.EnterBuild.After.invoke()
                } elseif ($Output.EnterBuild.After -is [string]) {
                    logEnter $Output.EnterBuild.After
                }
            }
        }
    }

    #endregion Before hook
    #-------------------------------------------------------------------------------

    Write-Debug "`n$('-' * 80)`n-- End Enter-Build`n$('-' * 80)"
}
