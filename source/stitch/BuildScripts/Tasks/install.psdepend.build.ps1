
param(
    [Parameter()]
    [switch]$SkipDependencyCheck = (
        Get-BuildProperty SkipDependencyCheck $false
    )
)


#synopsis: Install PSDepend2 for managing requirements
task install.psdepend {
    if (-not($SkipDependencyCheck)) {
        logInfo 'Checking for PSDepend2'
        $psDependModule = Get-InstalledModule PSDepend2
        if ($null -ne $psDependModule) {
            logInfo "  - PSDepend2 $($PSDependModule.Version)is installed"
        } else {
            logInfo '  - Not Found.  Installing PSDepend2 in CurrentUser Scope'
            $installedModule = (Install-Module PSDepend2 -Scope CurrentUser -PassThru)
            if ($null -ne $installedModule) {
                logInfo "  - PSDepend2 $($installedModule.Version) was installed"
            }
        }
    }
}
