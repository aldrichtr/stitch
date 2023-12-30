<#
.SYNOPSIS
    Update the ModuleVersion field in the source manifest
.DESCRIPTION
    The version information is found using the `Get-ProjectVersionInfo` function.  Use the parameter
    `ProjectVersionSource` to specify where version information is pulled from, and `ProjectVersionField`
    to specify the field within the ProjectVersionInfo to use
#>

param(
    [Parameter()][string]$ProjectVersionField = (
        Get-BuildProperty ProjectVersionField 'MajorMinorPatch'
    ),

    [Parameter()][string]$ProjectVersionSource = (
        Get-BuildProperty ProjectVersionSource 'GitVersion'
    )
)

#synopsis: Update the version in the source module
task set.manifest.version {

    $options = @{}
    switch ($ProjectVersionSource) {
        'gitversion' {
            logDebug 'Using GitVersion for project version'
        }
        'gitdescribe' {
            $options['UseGitDescribe'] = $true
        }
        'file' {
            $options['UseVersionFile'] = $true
        }
        default {
            throw (logError "$ProjectVersionSource must be either 'gitversion', 'gitdescribe', or 'file'" -PassThru)
        }
    }
    $currentVersion = Get-ProjectVersionInfo @options
    Remove-Variable 'options'

    $BuildInfo | Foreach-Module {
        $config = $_
        $name = $config.Name
        $manifestFile = (Join-Path $config.Source $config.ManifestFile)
        $manifestObject = Import-Psd $manifestFile

        if ($null -ne $manifestObject) {
            $previousVersion = [version]$manifestObject.ModuleVersion
        } else {
            throw (logError "Could not load the current source manifest for $name" -PassThu)
        }
        if ($null -ne $currentVersion) {
            if ($currentVersion.ContainsKey($ProjectVersionField)) {
                try {
                    $currentVersion = [version]$currentVersion[$ProjectVersionField]
                } catch {
                    throw (logError "$currentVersion[$ProjectVersionField] is not a valid version`n$_" -PassThu)
                }
            } else {
                throw (logError "Project Version Info does not cantain the field $ProjectVersionField" -PassThu)
            }
        }

        if ($null -eq $currentVersion) {
            throw (logError 'The current version of the project could not be set' -PassThu)
        }

        if ($null -eq $previousVersion) {
            throw (logError "Could not read the version information in $manifestFile" -PassThu)
        }

        if ($currentVersion -le $previousVersion) {
            logInfo "$name already at $previousVersion when trying to set version $currentVersion"
        } else {
            logInfo "Updating source module from $previousVersion to $currentVersion"

            $options = @{
                Path         = $manifestFile
                PropertyName = 'ModuleVersion'
                Value        = $currentVersion
            }

            try {
                Update-Metadata @options
            } catch {
                throw (logError "Could not update version in $manifestFile`n$_" -PassThru)
            }
        }
    }
}
