param(
    [Parameter()][string]$PublishPsRepoName = (
        Get-BuildProperty PublishPsRepoName 'psgallery'
    ),

    [Parameter()][string]$NugetApiKey = (
        Get-BuildProperty NugetApiKey ''
    ),

    [Parameter()][string]$PublishActionIfUncommitted = (
        Get-BuildProperty PublishActionIfUncommitted 'ignore'
    )
)

#synopsis: Publish the package to the repository in PublishPSRepoName
task publish.nuget.package {
    $gitStatus = Get-GitRepositoryStatus

    if ($gitStatus.IsDirty) {
        logWarn "git repository has uncommited changes"
        switch ($PublishActionIfUncommitted) {
            'stash' {
                logInfo "Calling push.git.stash task"
                call 'push.git.stash'
            }
            'ignore' {
                logInfo "Ignoring uncommited changes"
            }
            'abort' {
                throw (logError "Publish cancelled because uncommited changes exist and PublishActionIfUncommited is set to 'abort'" -PassThru)
            }
        }
    }
    $psRepository = (Get-PSRepository | Where-Object {
        $_.Name -like $PublishPsRepoName
    })
    if ($null -ne $psRepository) {
         $BuildInfo | Foreach-Module {
            $config = $_
            $name = $config.Name
            $manifestVersion = Get-Metadata -Path (Join-Path $config.Staging $config.ManifestFile) -PropertyName ModuleVersion


            logInfo "Publishing $Name version $manifestVersion to $PublishPsRepoName"
            $options = @{
                Path       = $config.Staging
                Repository = $PublishPsRepoName
            }

            if (-not([string]::IsNullorEmpty($NugetApiKey))) {
                $options['NugetApiKey'] = $NugetApiKey
            }
            try {
                Publish-Module @options
            } catch {
                throw (logError "Could not publish $Name to $PublishPsRepoName" -PassThru)
            }
        }
    } else {
        logError "Could not find PSRepository $PublishPsRepoName"
    }
}
