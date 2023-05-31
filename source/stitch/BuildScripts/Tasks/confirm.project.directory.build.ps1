
#synopsis: If missing, create the top-level directories in the project
task confirm.project.directory {
    foreach ($var in @('Source', 'Staging', 'Tests', 'Artifact', 'Docs')) {
        $path = (Get-Variable $var -ValueOnly)
        if ($null -ne $path) {
            if (Confirm-Path $path) {
                logInfo (
                    ' - {0,-16} {1}' -f $path,
                    ((Get-Item $path) |
                        Resolve-Path -Relative -ErrorAction SilentlyContinue)
                )
            } else {
                logError "could not create $path"
            }
        }
    }
}
