
#synopsis: Re-import the modules found in the source directory
task import.module.source {
     $BuildInfo | Foreach-Module {
        $config = $_
        logInfo "  Removing $($config.Name) Module"
        Remove-Module $config.Name -Force -ErrorAction SilentlyContinue
        logInfo "  Importing $($config.Source) Module"
        Import-Module $config.Source -Force
    }
}
