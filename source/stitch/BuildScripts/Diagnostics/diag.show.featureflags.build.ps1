
#synopsis: List the feature flags and their current setting
task diag.show.featureflags {
    if ($null -ne $BuildInfo) {
        Write-Build DarkBlue "Getting feature flags"
        if ($BuildInfo.Contains('Flags')) {
            Write-Build DarkBlue "Has a flags table"
        }
        $flags = Get-FeatureFlag -Debug
        if ($null -ne $flags) {
            Write-Build DarkBlue "Found $($flags.Count) flags"
            foreach ($flag in $flags) {
                Write-Build White ("Name: $($flag.Name) ; Enabled: $($flag.Enabled) ; Description:`n$($flag.Description)")

            }
        }
    } else {
        Write-Build DarkRed "Couldn't load BuildInfo"
    }
}
