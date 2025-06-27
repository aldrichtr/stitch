param(
    [Parameter()][string]$ProjectPSRepoName = (
        Get-BuildProperty ProjectPSRepoName $BuildInfo.Project.Name
    )
)

#synopsis: unregister the temporary repo
task unregister.project.psrepo {
    logInfo "  Unregistering PSRepository $($ProjectPSRepoName)"
    if ((Get-PSRepository | Select-Object -ExpandProperty Name) -contains $ProjectPSRepoName) {
        Unregister-PSRepository -Name $ProjectPSRepoName
    }
}
