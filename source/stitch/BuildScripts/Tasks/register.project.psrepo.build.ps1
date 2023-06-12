param(
    [Parameter()][string]$ProjectPSRepoName = (
        Get-BuildProperty ProjectPSRepoName $BuildInfo.Project.Name
    )
)

#synopsis: create a temporary repository for the project
task register.project.psrepo {
    logDebug "Looking for PowerShell Repository $ProjectPSRepoName"
    if ((Get-PSRepository | Select-Object -ExpandProperty Name) -notcontains $ProjectPSRepoName) {
        $psRepoPath = Join-Path $Artifact $ProjectPSRepoName
        $null = if (-not(Test-Path $psRepoPath)) { mkdir $psRepoPath -Force }
        $localRepo = @{
            Name               = $ProjectPSRepoName
            SourceLocation     = $psRepoPath
            PublishLocation    = $psRepoPath
            InstallationPolicy = 'trusted'
            <#ProviderName    = 'PowerShellGet'#>
        }
        logInfo (
            'Registering PSRepository {0} at {1}' -f $localRepo.Name, $localRepo.PublishLocation
        )
        $register = Register-PSRepository @localRepo | Out-String
        logDebug $register
    } else {
        logInfo "$ProjectPSRepoName already exists"
    }
}
