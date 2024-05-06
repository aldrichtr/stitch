
#synopsis: Create any missing directories for each module in Staging, Artifacts, and Docs
task confirm.module.directory {
    <#
    ---
    idempotent: true
    ---
    #>
    <#
        Each module should have a "Paths" entry, that lists the project directories the module should have,
        and then each of the project directories should have an entry that identifies the path like this:
        @{
            #... Build info
            Module1 = @{
                #... Module info
                Paths = @(
                    "Artifact",
                    "Docs",
                    "Source",
                    "Staging",
                    "Tests"
                )
                #... Module info
                Artifact = "c:\path\to\projects\Project\out\Module1"
                Docs = "c:\path\to\projects\Project\docs\Module1"
                #... for each "Path"
            }
        }
    #>
    if ($null -ne $BuildInfo) {
        $BuildInfo | Foreach-Module {
            $config = $_
            logInfo "Confirm directories for module $($config.Name)"
            foreach ($pathType in $config.Paths) {
                if ($null -ne $config.$pathType) {
                    $moduleDir = $config.$pathType
                    if (-not ([string]::IsNullorEmpty($moduleDir))) {
                        if (-not ($moduleDir | Test-Path)) {
                            try {
                                $result = New-Item $moduleDir -ItemType Directory
                                logInfo "Created directory $($result.Name)"
                            } catch {
                                throw "Could not create directory $moduleDir`n$_"
                            }
                        } else {
                            logInfo "$moduleDir already exists"
                        }


                    } else {
                        logInfo "$($config.Name) does not have a $pathType path configured"
                    }
                }
            }
        }
    }
}
