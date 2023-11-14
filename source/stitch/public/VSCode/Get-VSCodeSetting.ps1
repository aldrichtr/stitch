function Get-VSCodeSetting {
    [CmdletBinding()]
    param(
        # The name of the setting to return
        [Parameter(
            Position = 0
        )]
        [string]$Name,

        # Treat the Name as a regular expression
        [Parameter(
        )]
        [switch]$Regex
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $settingsFile = "$env:APPDATA\Code\User\settings.json"
    }
    process {
        if (Test-Path $settingsFile) {
            Write-Debug "Loading the settings file"
            $settings = Get-Content $settingsFile | ConvertFrom-Json -Depth 16 -AsHashtable
        }

        if ($PSBoundParameters.ContainsKey('Name')) {
            if ($Regex) {
                Write-Debug "Looking for settings that match $Name"
                $matchedKeys = $settings.Keys | Where-Object { $_ -match $Name }
            } else {
                Write-Debug "Looking for settings that are like $Name"
                $matchedKeys = $settings.Keys | Where-Object { $_ -like $Name }
            }
            if ($matchedKeys.Count -gt 0) {
                Write-Debug "Found $($matchedKeys.Count) settings"
                $settingsSubSet = @{}
                foreach ($matchedKey in $matchedKeys) {
                    $settingsSubSet[$matchedKey] = $settings[$matchedKey]
                }
                Write-Debug "Creating settings subset"
                $settings = $settingsSubSet
            }
        }

        $settings['PSTypeName'] = 'VSCode.SettingsInfo'
        [PSCustomObject]$settings | Write-Output
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
