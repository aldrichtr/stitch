
#synopsis: Re-import the modules found in the stage directory
task import.module.stage {
     $BuildInfo | Foreach-Module {
        $config = $_
        logInfo "  Removing $($config.Name) Module"
        Remove-Module $config.Name -Force -ErrorAction SilentlyContinue
        logInfo "  Importing $($config.Stage) Module"
        Import-Module $config.Stage -Force
    }
}
