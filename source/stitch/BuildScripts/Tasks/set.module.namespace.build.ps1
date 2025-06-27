
param(
    [Parameter()]$ModuleNamespace = (
        Get-BuildProperty ModuleNamespace @{}
    )
)
#synopsis: Add a namespace to the module. To set a namespace for the module, set it in the hashtable 'ModuleNamespace'.
task set.module.namespace {
    logInfo 'Checking modules for namespaces:'
     $BuildInfo | Foreach-Module {
        $config = $_
        $name = $config.Name
        if ($null -ne $ModuleNamespace) {
            if ($ModuleNamespace.ContainsKey($name)) {
                $ns = $ModuleNamespace[$name]
                logInfo "Module $name is in Namespace $ns"
                $stagingManifest = (Join-Path $config.Staging $config.Manifest)
                $stagingModule = (Join-Path $config.Staging $config.Module)

                assert (Test-Path $stagingManifest) "No manifest found for $name"
                assert (Test-Path $stagingModule) "No module found for $name"

                $newName = -join @($ns, '.', $name)

                logInfo 'Updating the module'
                logInfo "  - Renaming the module from $name.psm1 to $newName.psm1"
                Move-Item $stagingModule -Destination (
                    $stagingModule -replace "$name.psm1", "$newName.psm1"
                )

                logInfo 'Updating the manifest'
                logInfo "  - Renaming the module in the manifest from $name.psm1 to $newName.psm1"
                Update-Metadata -Path $stagingManifest -PropertyName 'RootModule' -Value "$newName.psm1"
                logInfo "  - Renaming the manifest from $name.psd1 to $newName.psd1"
                Move-Item $stagingManifest -Destination (
                    $stagingManifest -replace "$name.psd1", "$newName.psd1"
                )

                logInfo 'Updating the staged folder name'
                logInfo "  - Renaming the folder from $($config.Staging) to $newName"
                Move-Item $config.Staging -Destination (Join-Path (Get-Item $config.Staging).Parent $newName)
            } else {
                logDebug "$name does not have a Namespace set"
            }
        }
    }
}
