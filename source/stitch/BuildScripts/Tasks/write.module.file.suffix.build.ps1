param(
    [Parameter()][string]$ModuleFileSuffix = (
        Get-BuildProperty ModuleFileSuffix ''
    )
)

#synopsis: Add content to the end of the module file.  See ModuleFileSuffix
task write.module.file.suffix {
    if (-not([string]::IsNullOrEmpty($ModuleFileSuffix))) {
        $suffixStart = (-join  @(
            '#', ('=' * 79), [Environment]::NewLine,
            '#region suffix', [Environment]::NewLine
        ))
        $suffixEnd = (-join  @(
            '#endregion suffix', [Environment]::NewLine,
            '#', ('=' * 79), [Environment]::NewLine
        ))

         $BuildInfo | Foreach-Module {
            $config = $_
            $name = $config.Name
            $suffixFile = (Join-Path $config.Source $ModuleFileSuffix)
            if (Test-Path $suffixFile) {
                logInfo "Adding contents of $suffixFile to $name module"
                $suffixContent = (Get-Content $suffixFile)
            } else {
                logInfo "Adding $ModuleFileSuffix to $name module"
                $suffixContent = $ModuleFileSuffix
            }
            $moduleFile = (Join-Path $config.Staging $config.ModuleFile)
            if (Test-Path $moduleFile) {
                $suffixStart | Add-Content $moduleFile
                $suffixContent | Add-Content $moduleFile
                $suffixEnd | Add-Content $moduleFile
            } else {
                logError "Could not find $moduleFile when trying to add suffix"
            }
        }
    }
}
