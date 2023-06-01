param(
    [string]$NewName
)

if (-not($Host.Name -like 'Visual Studio Code Host')) {
    throw "Must be run inside VSCode PS Extension Host"
}

$ctx = $psEditor.GetEditorContext()

$currentFile = $ctx.CurrentFile

$fileItem = Get-Item $currentFile.Path

Write-Output "Looking in $($fileItem.Name)"


Write-Output "Looking for task token"
$taskToken = $currentFile.Tokens | Where-Object Text -Match '^task' | Select-Object -First 1

if ($null -ne $taskToken) {
    $taskLine = $taskToken.Extent.StartScriptPosition.Line
    Write-Output "Found task token $taskLine"
} else {
    throw "Could not find a task token"
}


if (-not([string]::IsNullorEmpty($taskLine))) {
    $null = $taskLine -match '^task\s+(\S+)\s+.*$'
    if ($Matches.Count -gt 0) {
        $taskName = $Matches.1
        Write-Output "The task name is $taskName"
        $newContent = ($fileItem | Get-Content -Raw) -replace [regex]::Escape($taskLine) , "task $newName {`n"
        Write-Output "Replacing $taskName with $newName in $($fileItem.Name)"
        $newContent | Set-Content $fileItem -Encoding utf8NoBOM
    } else {
        throw "could not find task name in line $taskLine"
    }
} else {
    throw "could not find a task line in $($fileItem.Name)"
}

$newPath = $fileItem.FullName -replace [regex]::Escape($fileItem.BaseName) , "$NewName.build"

Move-Item $fileItem $newPath
"New Path is $newPath"

$psEditor.Workspace.OpenFile($newPath)
