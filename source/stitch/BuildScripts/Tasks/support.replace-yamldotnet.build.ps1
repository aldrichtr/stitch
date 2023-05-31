
#synopsis: Replace the PlatyPS version of YamlDotNet with the latest version from this system
task support.replace-yamldotnet {
    $platyPSLocation = ((Get-InstalledModule -Name PlatyPS) | Select-Object -ExpandProperty InstalledLocation)
    $yamlLocation = ([System.AppDomain]::CurrentDomain.GetAssemblies() |
            Where-Object FullName -Like 'YamlDotNet*' |
                Select-Object -ExpandProperty Location)
    logInfo 'Renaming the dll in the PlatyPS directory'
    Get-ChildItem $platyPSLocation -Filter "YamlDotNet.dll" |
         Rename-Item -NewName {$_.name -replace '\.dll$', '.old'}
    logInfo 'Copying the latest version to the PlatyPS directory'
    Copy-Item $yamlLocation $platyPSLocation
}
