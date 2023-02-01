$Module = Get-Module stitch -ErrorAction SilentlyContinue
if ( $null -eq $Module) {
    $projectPath = (Get-Item ($PSCommandPath -replace '\\tests\\Unit\\.*$', ''))
    Import-Module (Join-Path $projectPath 'source' 'stitch')
    $Global:StitchModuleLoaded = $true
}
