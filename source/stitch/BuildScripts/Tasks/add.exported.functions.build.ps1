<#
.SYNOPSIS
    Add the functions to the manifest that should be exported from the module
.DESCRIPTION
    Foreach module add the functions with the Visibility of 'public' to the manifest in the Staging directory, in
    the 'FunctionsToExport' field

    To exclude a specific function from beinf added to the manifest, add its name to the 'ExcludeFunctionsFromExport' list
.LINK
    Get-SourceItem
    Get-SourceTypeMap
    format.manifest.file.array
#>

param(
    [Parameter()][string[]]$ExcludeFunctionsFromExport = (
        Get-BuildProperty ExcludeFunctionsFromExport @()
    )
)

<#
.SYNOPSIS
    Add the functions to the manifest that should be exported from the module
#>
task add.exported.functions {
     $BuildInfo | Foreach-Module {
        $config = $_
        $name = $config.Name
        $manifestFile = (Join-Path $config.Staging $config.ManifestFile)
        logInfo "Adding public functions to $name in $manifestFile"
        $publicFunctions = @()
        :item foreach ($item in $config.SourceInfo) {
            if (( $item.Type -like 'function') -and ($item.Visibility -like 'public')) {
                if ( $ExcludeFunctionsFromExport -contains $item.Name) {
                    logInfo "Not adding public function $($item.Name) because it is listed in ExcludeFunctionsFromExport"
                    continue item
                } else {

                    $publicFunctions += ($item | Select-Object -ExpandProperty 'Name')
                }
            }
        }

        if ($publicFunctions.Count -gt 0) {
            logDebug "Found $($publicFunctions.Count) public functions for $name"
            if (Test-Path $manifestFile) {
                Update-Metadata -Path $manifestFile -PropertyName 'FunctionsToExport' -Value $publicFunctions
            } else {
                throw (logError "Could not add public functions to $manifestFile. File not found" -Passthru)
            }
        } else {
            logInfo "No public functions found in $name"
        }
    }
}
