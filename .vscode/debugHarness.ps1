Remove-Module BuildTool -ErrorAction SilentlyContinue
Import-Module ".\source\BuildTool\BuildTool.psd1" -Force

$task_name = Read-Host "What task do you want to run?"

Invoke-Build $task_name
