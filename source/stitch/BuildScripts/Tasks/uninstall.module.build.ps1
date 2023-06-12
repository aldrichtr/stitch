
#synopsis: Uninstall the project's modules from the current system
task uninstall.module {
     $BuildInfo | Foreach-Module {
        $name = $_.Name
        logInfo "Removing $name from session"
        Remove-Module $name -Force
        logInfo "Uninstalling $name"
        Uninstall-Module $name
    }
}
