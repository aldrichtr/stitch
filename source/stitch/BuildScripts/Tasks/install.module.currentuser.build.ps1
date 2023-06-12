
param(
    [Parameter()][string]$InstallModuleFromPsRepo = (
        Get-BuildProperty InstallModuleFromPsRepo 'local'
    )
)
#synopsis: Install the project's modules into the CurrentUser Scope
task install.module.currentuser {
     $BuildInfo | Foreach-Module {
        $config = $_
        logInfo "Checking for $InstallModuleFromPsRepo PSRepository"
        $repo = Get-PSRepository $InstallModuleFromPsRepo -ErrorAction SilentlyContinue
        if ($null -ne $repo) {
            logInfo "Checking for $($config.Name) from $InstallModuleFromPsRepo PSRepository"
            $found = Find-Module -Name $config.Name -Repository $InstallModuleFromPsRepo -ErrorAction SilentlyContinue
            if ($null -ne $found) {
                logInfo "Installing $($config.Name) from $InstallModuleFromPsRepo PSRepository to CurrentUser"
                Install-Module $config.Name -Repository $InstallModuleFromPsRepo -Scope CurrentUser
            }


        }
    }
}
