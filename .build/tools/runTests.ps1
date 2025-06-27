#Requires -Modules @{ ModuleName = "Pester"; ModuleVersion = "5.4.0"}

param(
    [Parameter()]
    [string]$ConfigFile,

    [Parameter()]
    [string]$HelperModule
    )

    if (-not ($PSBoundParameters.ContainsKey('ConfigFile'))) {
        $options = @{
            Path = (Get-Location)
            ChildPath = '.build\profiles\default\pester'
            AdditionalChildPath = 'UnitTests.config.psd1'

        }
        $ConfigFile = (Join-Path @options)
        Remove-Variable -Name 'options'
    }

    if (-not ($PSBoundParameters.ContainsKey('HelperModule'))) {
        $options = @{
            Path = (Get-Location)
            ChildPath = 'tests'
            AdditionalChildPath = 'TestHelpers.psm1'
        }
        $HelperModule = (Join-Path @options)
        Remove-Variable -Name 'options'

    }

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
