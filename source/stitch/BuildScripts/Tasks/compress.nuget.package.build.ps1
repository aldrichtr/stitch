param(
    [Parameter()][string]$ProjectPSRepoName = (
        Get-BuildProperty ProjectPSRepoName $BuildInfo.Project.Name
    )
)

#synopsis: Generate a nuget package from the files in Staging.
task compress.nuget.package {
    if ([string]::IsNullorEmpty($ProjectPSRepoName)) {
        $ProjectPSRepoName = Resolve-ProjectName
    }
    logDebug "Looking for $ProjectPSRepoName before continuing"
    $psRepository = (Get-PSRepository | Where-Object {
        $_.Name -like $ProjectPSRepoName
    })
    if ($null -ne $psRepository) {
        logInfo "$ProjectPSRepoName repository found"
        $BuildInfo | Foreach-Module {
            $config = $_
            $name = $config.Name
            $manifestVersion = Get-Metadata -Path (Join-Path $config.Staging $config.ManifestFile) -PropertyName ModuleVersion
            logDebug "ManifestVersion is $manifestVersion"
            if ($null -ne $manifestVersion) {
                $existingPackages = Get-ChildItem -Path $Artifact -Filter "$name.$manifestVersion.nupkg" -Recurse
                if ($null -ne $existingPackages) {
                    logWarn "$Artifact contains existing packages for $manifestVersion of $name"
                    logInfo "Removing previous $manifestVersion packages"
                    try {
                        $existingPackages | Remove-Item
                    } catch {
                        throw "There was an error removing previous $manifestVersion packages of $name`n$_"
                    }
                }
            } else {
                logInfo "Could not get the version for module $name"
            }

            logInfo "Creating nupkg file for $Name using PSRepository $ProjectPSRepoName"
            $options = @{
                Path       = $config.Staging
                Repository = $ProjectPSRepoName
            }
            Publish-Module @options
        }
    } else {
        logError "Could not find PSRepository $ProjectPSRepoName"
    }
}
