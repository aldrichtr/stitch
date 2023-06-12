
param(
    [Parameter()]
    [switch]$SkipDependencyCheck = (
        Get-BuildProperty SkipDependencyCheck $false
    ),

    [Parameter()][string[]]$DependencyTags = (
        Get-BuildProperty DependencyTags @()
    )
)


#synopsis: Install modules required for developing powershell modules using PSDepend2
task set.psmodulepath {
    if (-not($SkipDependencyCheck)) {
        $targets = [System.Collections.ArrayList]@()
        $targets = Get-Dependency -Tags:$tags -Recurse:$true |
            Select-Object -ExpandProperty Target -Unique |
                Where-Object {
                    ($_ -notlike 'CurrentUser') -or
                    ($_ -notlike 'AllUsers')
                }

        if ($targets.count -gt 0) {
            logInfo 'Checking the Target option for the dependencies'
            $modulePaths = ([Environment]::GetEnvironmentVariable('PSModulePath') -split ';')
            $pathCount = $modulePaths.Count
            logDebug = "PSModulePath contains $pathCount paths"
            foreach ($target in $targets) {
                if (Test-Path $target) {
                    logDebug "Looking for $target in PSModulePath"
                    if ($modulePaths -contains $targetPath) {
                        logInfo "$target already set"
                    } else {
                        logInfo "Prepending $target on PSModulePath"
                        $modulePaths = $target , $modulePaths
                    }
                } else {
                    logWarn "Skipping $targetPath because it does not exist"
                }
            }
        }
        #! did the count increase since we started?
        if ($modulePaths.Count -gt $pathCount) {
            logInfo "Updating PSModulePath environment variable"
            [Environment]::SetEnvironmentVariable('PSModulePath', ($new_mod_paths -join ';'))
        } else {
            logInfo "No paths need to be added"
        }
    } else {
        logInfo "Module dependency check skipped (-SkipDependencyCheck was set)"
    }
}
