param(
    [Parameter()][string]$FormatPsXmlDirectory = (
        Get-BuildProperty FormatPsXmlDirectory 'formats'
    ),
    [Parameter()][string]$FormatPsXmlFileFilter = (
        Get-BuildProperty FormatPsXmlFileFilter '*Format.ps1xml'
    )
)

#synopsis: Add any format files found in the staging directory's format directory to the Manifest. Ensure that you add your formats source directory to the 'CopyAdditionalItems' table
task add.psformat.files {
     $BuildInfo | Foreach-Module {
        $config = $_

        $formatDir = (Join-Path $config.Staging $FormatPsXmlDirectory)
        if (Test-Path $formatDir) {
            logInfo "Looking for `"Format`" files for $($config.Name) in $formatDir"
            $options = @{
                Path = $formatDir
                Filter = $FormatPsXmlFileFilter
            }
            $formatFiles = Get-ChildItem @options

            if($formatFiles.Count -gt 0) {
                $manifestFile = (Join-Path $config.Staging $config.ManifestFile)

                $formatsList = @()
                foreach ($file in $formatFiles) {
                    $formatsList += [System.IO.Path]::GetRelativePath((Get-Item $manifestFile).Directory , $file.FullName)
                }
                logInfo "$($formatFiles.Count) Format files found"
                if (Test-Path $manifestFile) {
                    $manifestFile | Update-ManifestField 'FormatsToProcess' $formatsList
                }

            }
        }
    }
}
