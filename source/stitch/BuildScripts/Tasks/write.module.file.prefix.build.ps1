param(
    [Parameter()][string]$ModuleFilePrefix = (
        Get-BuildProperty ModuleFilePrefix ''
    )
)

#synopsis: Add content to the top of the module file
task write.module.file.prefix {
    if (-not ([string]::IsNullOrEmpty($ModuleFilePrefix))) {
        $prefixStart = ( -join @(
                '#', ('=' * 79), [Environment]::NewLine,
                '#region prefix', [Environment]::NewLine
            ))
        $prefixEnd = ( -join @(
                '#endregion prefix', [Environment]::NewLine,
                '#', ('=' * 79), [Environment]::NewLine
            ))

         $BuildInfo | Foreach-Module {
            $config = $_
            $name = $config.Name
            $prefixFile = (Join-Path $config.Source $ModuleFilePrefix)
            if (Test-Path $prefixFile) {
                logInfo "Adding contents of $prefixFile to $name module"
                $prefixContent = (Get-Content $prefixFile)
            } else {
                logDebug "Adding $ModuleFilePrefix to $name module"
                logInfo "Adding prefix message to $name module"
                $prefixContent = $ModuleFilePrefix
            }
            $moduleFile = (Join-Path $config.Staging $config.ModuleFile)
            if (-not (Test-Path $moduleFile)) {
                try {
                    $null = New-Item -Path $moduleFile -ItemType File
                } catch {
                    throw "Could not create $moduleFile`n$_"
                }
            }
            $moduleContent = Get-Content $moduleFile

            $prefixStart | Set-Content $moduleFile
            $prefixContent | Add-Content $moduleFile
            $prefixEnd | Add-Content $moduleFile
            $moduleContent | Add-Content $moduleFile
        }
    }
}
