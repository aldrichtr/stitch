param(
    [Parameter()][string]$ManifestVersionField = (
        property ManifestVersionField 'MajorMinorPatch'
    )
)

#synopsis: Update the version in the source module
task set.manifest.version {
     $BuildInfo | Foreach-Module {
        $config = $_
        $name = $config.Name
        $manifestFile = (Join-Path $config.Source $config.ManifestFile)
        $manifestObject = Import-Psd $manifestFile

        $previousVersion = [version]$manifestObject.ModuleVersion
        $currentVersion = [version]$BuildInfo.Project.Version[$ManifestVersionField]

        if ($null -eq $currentVersion) {
            throw 'The current version of the project is not set'
        }

        if ($null -eq $previousVersion) {
            throw "Could not read the version information in $manifestFile"
        }

        if ($currentVersion -le $previousVersion) {
            logInfo "$name already at $previousVersion when trying to set version $currentVersion"
        } else {
            logInfo "Updating source module from $previousVersion to $currentVersion"

            $options = @{
                Path = $manifestFile
                PropertyName = 'ModuleVersion'
                Value = $currentVersion
            }

            try {
                Update-Metadata @options
            }
            catch {
                throw (logError "Could not update version in $manifestFile`n$_" -PassThru)
            }
        }
    }
}
