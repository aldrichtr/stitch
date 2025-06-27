
param(
    # parameter help description
    [Parameter()][string]$HelpDocsCultureDirectory = (
        Get-BuildProperty HelpDocsCultureDirectory 'en-US'
    )
)
#synopsis: Generate MAML help file in the staged module directory
task write.externalhelp.file {
    try {
        $mod = Get-InstalledModule PlatyPS -ErrorAction SilentlyContinue
        if ($null -ne $mod) {
            Import-Module PlatyPS # this may throw an error if powershell-yaml is already loaded
             $BuildInfo | Foreach-Module {
                logDebug "  Checking for markdown files for $name"
                $config = $_
                $name = $config.Name
                if ((Get-ChildItem $config.Docs -Filter *.md).Count -gt 0) {
                    logInfo " Generating the external help for '$name' from the docs in $($config.Docs) folder"
                    $null = New-ExternalHelp $config.Docs -OutputPath (Join-Path $config.Staging $HelpDocsCultureDirectory) -Force
                } else {
                    logWarn "  No markdown files found in $($config.Docs)"
                }
            }
        }
    } catch [System.IO.FileLoadException] {
        if ($_.Exception | Select-String -Pattern 'Assembly with same name is already loaded' -SimpleMatch) {
            $yamlLocation = [System.AppDomain]::CurrentDomain.GetAssemblies() |
                Select-String YamlDotNet |
                    Select-Object -ExpandProperty Location
            logError 'The version of YamlDotNet that comes with PlatyPS is very old!'
            logError "Consider replacing it with the one found at :`n<$yamlLocation>"
            logError "You can run 'Invoke-Build support.replace-yamldotnet' in this project"
        }
    }
}
