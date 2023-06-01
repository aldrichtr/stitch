#Requires -Modules @{ ModuleName = "Pester"; ModuleVersion = "5.4.0"}

param(
    [Parameter()]
    [string]$ConfigFile
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

Invoke-Pester -Configuration $pesterConfig
