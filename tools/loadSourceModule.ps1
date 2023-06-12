param(
    [switch]$UseBuildTool
)

Write-Host -Object "Load Source Module Script" -ForegroundColor Blue

if ($UseBuildTool) {
    Write-Host -Object "*** Currently using BuildToolProject ***" -ForegroundColor Yellow
    Write-Host -Object 'Unloading any BuildTool modules  ' -ForegroundColor DarkGray -NoNewline
    Remove-Module BuildTool -ErrorAction SilentlyContinue
    Write-Host -Object 'Done' -ForegroundColor DarkGreen


    Write-Host -Object 'Loading BuildTool module from the source directory  ' -ForegroundColor DarkGray -NoNewline
    Import-Module '..\BuildToolProject\source\BuildTool\BuildTool.psd1' -Force
    Write-Host -Object 'Done' -ForegroundColor DarkGreen

    $bt = Get-Module BuildTool
    Write-Host -Object "BuildTool version $($bt.Version) loaded from $($bt.Path)"

} else {
    Write-Host -Object 'Unloading any stitch modules  ' -ForegroundColor DarkGray -NoNewline
    Remove-Module stitch -ErrorAction SilentlyContinue
    Write-Host -Object 'Done' -ForegroundColor DarkGreen


    Write-Host -Object 'Loading stitch module from the source directory  ' -ForegroundColor DarkGray -NoNewline
    Import-Module '.\source\stitch\stitch.psd1' -Force
    Write-Host -Object 'Done' -ForegroundColor DarkGreen

    $bt = Get-Module stitch
    Write-Host -Object "stitch version $($bt.Version) loaded from $($bt.Path)"
}
