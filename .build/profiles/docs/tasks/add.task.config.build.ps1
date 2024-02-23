
#Synopsis: Create task config files from the source
task add.task.config {
    logDebug "CopyAdditional: ($($CopyAdditionalItems | ConvertTo-Psd))"
    Import-Module '.\tools\BuildProperties.psm1'

    $taskConfigDir = '.\.build\profiles\default\config\tasks'
    $scriptPropertyMap = Get-BuildScriptProperty

    $propertyData = Get-ParameterData
    #TODO: To make this task idempotent, the additon should skip if the field and value already exist

    foreach ($map in $scriptPropertyMap.GetEnumerator()) {
        $name = $map.Name
        logDebug "Property: $name"
        try {
            $currentValue = Get-BuildProperty $name
        } catch {
            $currentValue = (Get-Variable $name -ValueOnly)
        }
        logDebug "Value: $($currentValue | ConvertTo-Psd)"
        $commentText = (
            ($propertyData
            | Where-Object Name -Like $name
            | Select-Object -Expand Help
            ) -join "`n")

        $instances = $map.Value
        :file foreach ($instance in $instances) {
            $taskConfigFile = $instance.File -replace 'build\.ps1', 'config.psd1'
            logDebug "- Task configuration file: $taskConfigFile"
            $taskConfigPath = (Join-Path $taskConfigDir $taskConfigFile)

            if (Test-Path $taskConfigPath) {
                logDebug "  - already exists"
                $currentContent = Import-Psd $taskConfigPath
                if ($currentContent.ContainsKey($name)) {
                    logDebug "    - already has a $name key"
                    if ($currentContent['$name'] -eq $currentValue) {
                        logDebug "    - and content matches"
                        continue file
                    } else {
                        logDebug "    - but content doesn't match"
                        $xml = Import-PsdXml -Path $taskConfigPath
                        Set-Psd -Xml $xml -Value $currentValue -XPath (-join ('//Data/Table/Item[@Key="', $name, '"]'))
                        Export-PsdXml -Path $taskConfigPath -Xml $xml
                        continue file
                    }
                } else {
                    logDebug "    - does not have a $name key"
                    $xml = Import-PsdXml -Path $taskConfigPath
                    $table = $xml.Data.Table
                    $newLine = $xml.CreateElement('NewLine')
                    $comment = $xml.CreateElement('Comment')
                    [void]$table.AppendChild($newLine)
                    [void]$table.AppendChild($comment)
                    [void]$table.AppendChild($newLine)
                    $currentValueData = $currentValue | ConvertTo-Psd | Convert-PsdToXml
                    $newItem = $xml.CreateElement('Item')
                    [void]$newItem.SetAttribute('Key', $name)
                    $newItem.InnerXml = $currentValueData

                    Export-PsdXml -Path $taskConfigPath -Xml $xml
                }
            } else {
                logDebug "  - does not exist"
                $data = @{
                    $name = $currentValue
                }

                $data | ConvertTo-Psd | Set-Content $taskConfigPath
                $xml = Import-PsdXml -Path $taskConfigPath
                $newLine = $xml.CreateElement('NewLine')
                $comment = $xml.CreateElement('Comment')
                $comment.InnerText = (-join (
                        '<# ',
                        $commentText,
                        ' #>'))
                $table = $xml.Data.Table
                [void]$table.PrependChild($newLine)
                [void]$table.PrependChild($comment)
                [void]$table.PrependChild($newLine)
                Export-PsdXml -Path $taskConfigPath -Xml $xml
            }
            $taskConfigPath | Convert-LineEnding -LF
        }
    }
}
