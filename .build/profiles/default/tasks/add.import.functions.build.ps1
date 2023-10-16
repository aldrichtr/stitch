param(
)

# .SYNOPSIS Add the Import-BuildScript and Import-TaskFile to the Exported functions
task add.import.functions {
    $importFunctions = @('Import-BuildScript', 'Import-TaskFile')
    $config  = $BuildInfo.Modules['stitch']

    $manifestFile = (Join-Path $config.Staging $config.ManifestFile)
    $currentExportedFunctions = [System.Collections.ArrayList]@(
            (Get-Metadata -Path $manifestFile -PropertyName 'FunctionsToExport')
    )

    $importFunctions
    | ForEach-Object {
        $currentExportedFunctions.Add($_)
    }

    $options = @{
        Path = $manifestFile
        PropertyName = 'FunctionsToExport'
        Value = $currentExportedFunctions
    }

    Update-Metadata @options

}
