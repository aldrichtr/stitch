param(
    [Parameter()][string]$TypePsXmlDirectory = (
        Get-BuildProperty TypePsXmlDirectory 'types'
    ),
    [Parameter()][string]$TypePsXmlFileFilter = (
        Get-BuildProperty TypePsXmlFileFilter '*.Types.ps1xml'
    )
)

#synopsis: Add the types found
task add.pstype.files {
     $BuildInfo | Foreach-Module {
        $config = $_

        $typesDir = (Join-Path $config.Staging $TypePsXmlDirectory)
        if (Test-Path $typesDir) {
            logInfo "Looking for `"Types`" files for $($config.Name) in $typesDir"
            $options = @{
                Path   = $typesDir
                Filter = $TypesPsXmlFileFilter
            }
            $typesFiles = Get-ChildItem @options

            if($typesFiles.Count -gt 0) {
                $manifestFile = (Join-Path $config.Staging $config.ManifestFile)

                $typesList = @()
                foreach ($file in $typesFiles) {
                    $typesList += [System.IO.Path]::GetRelativePath((Get-Item $manifestFile).Directory , $file.FullName)
                }
                logInfo "$($typesFiles.Count) Types files found"
                if (Test-Path $manifestFile) {
                    $manifestFile | Update-ManifestField 'TypesToProcess' $typesList
                }

            }
        }
    } }
