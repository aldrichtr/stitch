<#
a file with task ([a-zA-Z0-9\.]+)
#>

$taskFiles = gci .\source\stitch\BuildScripts -Filter "*.task.ps1" -Recurse
$buildFiles = gci .\source\stitch\BuildScripts -Filter "*.build.ps1" -Recurse