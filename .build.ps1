
task build-docs {
  $outputDir = "$BuildRoot\docs\en-US"
  if ($outputDir | Test-Path) {
    Write-Build Gray 'Output directory exists'
  } else {
    $null = New-Item -Path $outputDir -ItemType Directory -Force
    Write-Build Gray 'Output directory created'
  T}
  Import-Module Microsoft.PowerShell.PlatyPS

  $modulePage = (Join-Path $outputDir 'stitch.md')
  $mod = Import-Module "$BuildRoot\source\stitch" -Force
  if ($modulePage | Test-Path) {
      Write-Build Yellow "Updating module documentation"
    $mod | Update-MarkdownModuleFile -Path $modulePage -NoBackup
  } else {
      Write-Build Yellow "Creating module documentation"
    $mod | New-MarkdownModuleFile -OutputFolder $outputDir
  }
  foreach ($c in (Get-Command -Module 'stitch')) {
    $path = (Join-Path $outputDir "$($c.Name).md")
    if ($path | Test-Path) {
      Write-Build Yellow "Updating documentation for $($c.Name)"
      Update-MarkdownCommandHelp -Path $path
    } else {
      Write-Build Yellow "Creating documentation for $($c.Name)"
      New-MarkdownCommandHelp -CommandInfo $c -OutputFolder $outputDir
    }
  }
  $options = @{
    Path                  = $outputDir
    RefreshModulePage     = $true
    AlphabeticParamsOrder = $true
    UpdateInputOutput     = $true
    ExcludeDontShow       = $true
    LogPath               = "$BuildRoot\out\platyps-log-$(Get-Date -Format 'yyyy-MM-dd_HH:mm:ss')"
    Encoding              = [System.Text.Encoding]::UTF8
  }
  Update-MarkdownHelpModule @parameters
}
