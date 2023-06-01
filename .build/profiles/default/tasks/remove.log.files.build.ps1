
task remove.log.files {
    remove (Join-Path $Artifact "logs\*.log")
}
