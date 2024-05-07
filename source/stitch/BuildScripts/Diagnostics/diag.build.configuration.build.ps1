
#synopsis: Output the Build Configuration settings for debugging / tracing
task diag.build.configuration {
    logDebug 'Build Configuration:'
    $config = $BuildInfo
    foreach ($key in $config.Modules.Keys) {
        if ($null -ne $config.Modules[$key].SourceInfo) {
            $config.Modules[$key].SourceInfo = "Removed for format"
        }
    }
    Write-Build Gray ($config | ConvertTo-Psd -Indent 2 | Out-String)
    Write-Build Gray "$('-' * 80)"
}
