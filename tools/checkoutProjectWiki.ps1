$localWikiDirectory = ".\docs\wiki"

$projectUrl = Get-GitRemote
| Where-Object Name -like 'origin'
| Select-Object -ExpandProperty Url

if ($projectUrl -match '\.git$') {
    $projectWikiUrl = $projectUrl -replace '\.git$' , '.wiki.git'
} else {
    $projectWikiUrl = "$projectUrl.wiki.git"
}

Write-Host "project wiki is '$projectWikiUrl'"

Write-Host "cloning into $localWikiDirectory"

Copy-GitRepository -Source $projectWikiUrl -DestinationPath $localWikiDirectory
