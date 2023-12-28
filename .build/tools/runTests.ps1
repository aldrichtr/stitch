#Requires -Modules @{ ModuleName = "Pester"; ModuleVersion = "5.4.0"}

param(
    [Parameter()]
    [string]$ConfigFile = (Join-Path ".\.build\profiles\default\pester" "UnitTests.config.psd1"),

    [Parameter()]
    [string]$HelperModule = (Join-Path 'tests' 'TestHelpers.psm1')
)


if (Test-Path $ConfigFile) {
    try {
        $config = Import-PowerShellDataFile -Path $ConfigFile
        $pesterConfig = New-PesterConfiguration -Hashtable $config
    } catch {
        Write-Information "Could not import $ConfigFile"
    }
} else {
    Write-Information 'No Config File given running all tests in ./tests'
    $pesterConfig = New-PesterConfiguration -Hashtable @{
        Run = @{
            Path = './tests'
        }
    }
}

if (Test-Path $HelperModule) {
    Import-Module $helperModule -Force
} else {
    throw "Could not find test helper module"
}

Invoke-Pester -Configuration $pesterConfig
