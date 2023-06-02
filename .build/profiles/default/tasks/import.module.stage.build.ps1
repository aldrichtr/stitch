
#synopsis: Re-import the modules found in the stage directory
task import.module.stage {
    $BuildInfo | Foreach-Module {
        $config = $_
        if ($config.name -ne 'stitch') {
            logInfo "  Removing $($config.Name) Module"
            Remove-Module $config.Name -Force -ErrorAction SilentlyContinue
        } else {
            logInfo "Skipping remove stitch module while build is running"
        }

        logInfo "  Importing $($config.Stage) Module"
        Import-Module (Join-Path $config.Stage $config.ManifestFile) -Force
    }
}
