<#
.SYNOPSIS
    Add the required modules to the manifest from a list of modules from PSDepend, or the RequiredModules parameter
#>

param(
    [Parameter()][System.Object]$RequiredModules = (
        Get-BuildProperty RequiredModules 'PSDepend2'
    )
)

#synopsis: Add the required modules to the manifest from a list of modules from PSDepend, or the RequiredModules parameter
task add.required.modules {
    if (-not ([string]::IsNullorEmpty($RequiredModules))) {
        $usePSDepend  = $false
        $useHashTable = $false
        if ($RequiredModules -is [string]) {
            #! I use PSDepend2 because it has additional dependency types, but PSDepend would also work fine
            if ($RequiredModules -like "PSDepend*") {
                $psdependModule = Get-InstalledModule $RequiredModules -ErrorAction SilentlyContinue
                if ($null -ne $psdependModule) {
                    $usePSDepend = $true
                } else {
                    throw "$RequiredModules module specified in `$RequiredModules but it is not installed"
                }
            }
        } elseif ($RequiredModules -is [hashtable]) {
            $useHashTable = $true
        }
    }

    $BuildInfo | Foreach-Module {
        $config = $_
        $name = $config.name
        $manifestFile = (Join-Path $config.Staging $config.ManifestFile)

        if ($usePSDepend) {
            $RequiredModulesList = @()
            $dependencies = Get-Dependency -Recurse -Tags @($name, 'publish')
            foreach ($dependency in $dependencies) {
                $RequiredModulesList += @{
                    ModuleName = $dependency.DependencyName
                    ModuleVersion = $dependency.ModuleVersion
                }
            }
        } elseif ($useHashTable) {
            $RequiredModulesList = $RequiredModules[$name]
        }
        if ($RequiredModulesList.Count -gt 0) {
            if (Test-Path $manifestFile) {
                if ($manifestFile | Test-CommentedProperty 'RequiredModules') {
                    logDebug "Uncommenting 'RequiredModules in $manifestFile"
                    $manifestFile | ConvertFrom-CommentedProperty 'RequiredModules'
                }
                $required = Get-ManifestValue -Path $manifestFile -PropertyName 'RequiredModules' -ErrorAction SilentlyContinue
                if ($null -ne $required) {
                    Update-Metadata -Path $manifestFile -PropertyName 'RequiredModules' -Value $RequiredModulesList
                }
            } else {
                throw (logError "Could not add public functions to $manifestFile. File not found" -Passthru)
            }
        } else {
            logInfo "No Required Modules found for $name"
        }
    }
}
