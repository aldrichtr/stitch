param(
    [Parameter()]
    [string]$ConfigFile = 'pester.Unit.config.psd1'
)

if (Test-Path $ConfigFile) {

    $config = Import-Psd $ConfigFile
    $pesterConfig = New-PesterConfiguration -Hashtable $config
} else {
    $pesterConfig = New-PesterConfiguration -Hashtable @{
        Run = @{
            Path = './tests'
        }
    }
}

Invoke-Pester -Configuration $pesterConfig
