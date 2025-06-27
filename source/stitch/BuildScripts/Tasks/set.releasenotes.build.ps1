param(
    [Parameter()][string]$ReleaseNotesFormat = (
        Get-BuildProperty ReleaseNotesFormat 'Text'
    ),

    [Parameter()][string]$ReleaseNotesFile = (
        Get-BuildProperty ReleaseNotesFile 'ReleaseNotes.md'
    )
)


#synopsis: Add the staged release notes to the Manifest using 'here string'
task set.releasenotes {
     $BuildInfo | Foreach-Module {
        $config = $_

    if ($ReleaseNotesFormat -like 'text') {
        $releasenotesPath = (Join-Path $config.Staging $ReleaseNotesFile)
        if (Test-Path $releasenotesPath) {
            logDebug '   - Adding notes to staging manifest'
            $releasenotesData = ( -join @(
                "@'`n",
                ( Get-Content $releaseNotesPath -Raw),
                "`n'@"
                )
            )
        }
    } elseif ( $ReleaseNotesFormat -like 'url') {
            $releasenotesData = $config.ProjectUri + '/blob/main/ReleaseNotes.md'
    }
            $outputFile = (Join-Path $config.Staging $config.ManifestFile)
            if (Test-Path $outputFile) {
                $manifest = Import-Psd $outputFile
                if (-not($manifest.PrivateData.PSData.ContainsKey('ReleaseNotes'))) {
                    if ((Get-Content $outputFile) -match '\s*#\s*ReleaseNotes') {
                        logInfo "ReleaseNotes is commented out in manifest $outfile"
                        (Get-Content $outputFile) -replace '#\s*ReleaseNotes' , 'ReleaseNotes' | Set-Content $outputFile
                        logInfo 'Removed comment'
                    } else {
                        $xml = Import-PsdXml $outputFile
                        $PSData = $xml.SelectSingleNode('/Data/Table/Item[@Key="PrivateData"]/Table/Item[@Key="PSData"]')
                        $stringElement = $xml.CreateElement('String')
                        $stringElement.InnerText = ' '

                        $newItem = $xml.CreateElement('Item')
                        $newItem.SetAttribute('Key', 'ReleaseNotes')

                        $newLine = $xml.CreateElement('NewLine')

                        $newItem.AppendChild($stringElement)
                        $PSData.AppendChild($newItem).AppendChild($newLine)

                        Export-PsdXml -Path $outFile -Xml $xml
                    }
                }

                $options = @{
                    Path     = (Join-Path $config.Staging $config.ManifestFile)
                    Property = 'ReleaseNotes'
                    Value    = $releasenotesData
                }
                Update-Metadata @options
            } else {
                logWarn "No Manifest found at $outputFile"
            }

    }
}
