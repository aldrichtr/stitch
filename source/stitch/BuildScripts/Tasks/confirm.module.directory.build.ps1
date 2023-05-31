
#synopsis: Create any missing directories for each module in Staging, Artifacts, and Docs
task confirm.module.directory {
     $BuildInfo | Foreach-Module {
        $config = $_
        foreach ($path in $config.Paths) {
            if (Confirm-Path $config.$path) {
                logInfo (
                    ' - {0,-16} {1}' -f $path,
                        ((Get-Item $config.$path) |
                        Resolve-Path -Relative -ErrorAction SilentlyContinue)
                )
            } else {
                logError "Could not create $path"
            }
        }
    }
}
