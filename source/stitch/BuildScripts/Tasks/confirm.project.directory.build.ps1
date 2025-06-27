<#
.SYNOPSIS
If missing, create the top-level directories in the project
.DESCRIPTION
The standard project directories 'Source', 'Staging', 'Tests', 'Artifacts', 'Docs'.  Should be defined in the
BuildInfo variable, and they should be set to a directory. within the project.

If they are present, `confirm.project.directory` will skip it without error, if it is not it will be created.
.NOTES
---
@{
    idempotent = $true
}
---
.COMPONENT
Validate
#>
param()


task confirm.project.directory {
    <# data
    ---
    @{
        idempotent = $true
    }
    ---
    #>
    foreach ($var in @('Source', 'Staging', 'Tests', 'Artifact', 'Docs')) {
        logDebug "Processing info for $var directory"
        $path = $BuildInfo[$var]
        if ($null -ne $path) {
            if ($path | Test-Path) {
                logInfo "Path $var already exists at $path"
            } else {
                try {
                    $null = New-Item $path -ItemType Directory
                    logInfo "Path $var created at $path"

                } catch {
                    throw "Could not create required project directory $var at $path`n$_"
                }
            }
        } else {
            logError "BuildInfo does not contain a path for $var"
        }
    }
}
