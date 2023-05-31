
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
task install.requirement {
    if (-not($SkipDependencyCheck)) {
        logInfo 'Checking dependencies:'

        if (-not([string]::IsNullorEmpty($DependencyTags))) {
            $tags = $DependencyTags
        } else {
            $tags = @()
        }

        if ($null -ne $env:GITHUB_CONTEXT) {
            logDebug "Running in github action.  Adding appropriate tags"
            if ($tags -notcontains 'ci') {
                $tags += 'ci'
            }
            if ($tags -notcontains 'github') {
                $tags += 'github'
            }
        }

        #! Test-Dependency adds 'DependencyExists' to each object
        $dependencies = (Get-Dependency -Tags:$tags -Recurse:$true | Test-Dependency)

        $missing = $dependencies | Where-Object { (-not($_.DependencyExists)) }

        if ($missing.Count -gt 0) {
            logInfo "  $($missing.Count) dependencies not met.  Calling Invoke-PSDepend"
            Invoke-PSDepend -Force
        } else {
            logInfo 'All dependencies met'
        }
    } else {
        logInfo "Module dependency check skipped (-SkipDependencyCheck was set)"
    }
}
