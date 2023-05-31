param(
    [Parameter()][string]$FormatSettings = (
        Get-BuildProperty FormatSettings  (Join-Path $BuildRoot 'CodeFormatting.psd1')
    )
)


#synopsis: Format the manifest file (.psd1) in staging
task format.manifest.file {
     $BuildInfo | Foreach-Module {
        $config = $_
        logDebug "Formatting $($config.ManifestFile)"
        $options = @{
            Path = (Join-Path $config.Staging $config.ManifestFile)
        }
        if (-not ([string]::IsNullorEmpty($FormatSettings))) {
            switch ($FormatSettings) {
                ($_ -is [string]) {
                    if (Test-Path $FormatSettings) {
                        $options['Settings'] = $FormatSettings
                    }
                }
                ($_ -is [hashtable]) {
                    $options['Settings'] = $FormatSettings
                }
            }
        }
        $options.Path | Convert-LineEnding -CRLF
        Format-File @options
        Remove-Variable options -ErrorAction SilentlyContinue
    }
}
