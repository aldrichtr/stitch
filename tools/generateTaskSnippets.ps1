$snippetFile = (Join-Path '.vscode' 'powershell.code-snippets')

if (Test-Path $snippetFile) {
    $snippets = Get-Content $snippetFile | ConvertFrom-Json -AsHashtable
} else {
    $snippets = @{}
}

foreach ($task in (Invoke-Build ?)) {
    $snippets[$task.Name] = @{
        prefix = $task.Name
        description = $task.synopsis
        body = "'$($task.Name)'"
    }
}

$snippets | ConvertTo-Json | Set-Content $snippetFile
