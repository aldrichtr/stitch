
#synopsis: Format the module file (.psm1) in staging
task format.module.file {
     $BuildInfo | Foreach-Module {
        $config = $_
        logDebug "Formatting $($config.ModuleFile)"
        Format-File (Join-Path $config.Staging $config.ModuleFile)
    }
}
