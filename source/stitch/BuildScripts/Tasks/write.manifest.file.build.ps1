
param(
    [Parameter()][switch]$SuppressManifestComments = (
        Get-BuildProperty SuppressManifestComments $false
    )
)

#synopsis: Write the module manifest file (.psd1) for each module in the source directory
task write.manifest.file {
     $BuildInfo | Foreach-Module {
        $config = $_
        $name = $config.name
        $manifestFile = (Join-Path $config.Source $config.ManifestFile)
        $outputFile = (Join-Path $config.Staging $config.ManifestFile)

        if (Test-Path $outputFile) {
            try {
                Remove-Item $outputFile -Force
            }
            catch {
                throw "There was an error while removing previous manifest $outputFile`n$_"
            }
        }
        if ($SuppressManifestComments) {
            logInfo "SuppressManifestComments is set.  Copying from source"
            Copy-Item -Path $manifestFile -Destination $outputFile
        } else {
            $manifest = Import-Psd $manifestFile

            $options = $manifest.Clone()

            #! Use New-ModuleManifest so that order and commentary are conformant
            foreach ($item in $manifest.PrivateData.PSData.Keys.Clone()) {
                if (-not([string]::IsNullOrEmpty($manifest.PrivateData.PSData[$item]))) {
                    logDebug "Moving $($item) from PrivateData to Parameter"
                    $options[$item] = $manifest.PrivateData.PSData[$item]
                    $options.PrivateData.PSData.Remove($item)
                } else {
                    logDebug "$item is an empty string. Ignoring"
                }
            }
            $options.Remove('PrivateData')
            $options['Path'] = $outputFile
            logDebug "Generating manifest with:`n$($options | ConvertTo-Psd)"
            try {
                New-ModuleManifest @options
            } catch {
                throw "there was an error generating manifest $outputFile`n$_"
            }
        }
    }
}
