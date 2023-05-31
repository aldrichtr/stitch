param(
    [Parameter()]
    [string[]]$SkipManifestArrayFormat = (
        Get-BuildProperty SkipManifestArrayFormat @()
    )
)

# synopsis: Fix the format of array fields in the manifest files (add '@()' around values)
task format.manifest.file.array {
    $arrayFields = @(
        'RequiredModules',
        'RequiredAssemblies',
        'ScriptsToProcess',
        'TypesToProcess',
        'FormatsToProcess',
        'FunctionsToExport',
        'CmdletsToExport',
        'AliasesToExport',
        'VariablesToExport',
        'DscResourcesToExport',
        'ModuleList',
        'FileList',
        'Tags'
    )
     $BuildInfo | Foreach-Module {
        $config = $_
        $file = (Join-Path $config.Staging $config.ManifestFile)

        if (Test-Path $file) {
            logInfo 'Fixing the formatting of the manifest'
            logDebug "Removing '*' from manifest"
            (Get-Content $file) -replace  "'\*'", '@()' | Set-Content $file -Encoding  Utf8NoBOM
            foreach ($field in $arrayFields) {
                if ($SkipManifestArrayFormat -contains $field) {
                    logDebug "  - Skipping $field because it is listed in -SkipManifestArrayFormat"
                    continue
                }
                #! we use Get-Metadata because it handles nested values like 'Tags'
                $arrayMembers = Get-Metadata -Path $file -PropertyName $field -ErrorAction SilentlyContinue
                if ($null -ne $arrayMembers) {
                    # first, Update-Metadata will put them all on one line
                    Update-Metadata -Path $file -PropertyName $field -Value $arrayMembers
                    # next, surround members in single-quotes
                    $arrayMembers = ($arrayMembers -replace '(.+)', (-join @("'", '$1', "'")))
                    # then, create a nicely formatted array
                    $arrayString = (-join @(
                        "@(`n",
                        ($arrayMembers -join ",`r`n"),
                        "`r`n)"
                        ))
                    logInfo "Reformatting $field"
                    $content = (Get-Content $file)
                    if ($content -match "$([regex]::Escape($field))\s+=\s+@.*") {
                        logDebug "$($Matches.0) matches the $field field"
                    }
                    $content -replace "$([regex]::Escape($field))\s+=\s+@.*" , "$field = $arrayString`r`n" | Set-Content $file -Encoding utf8NoBOM
                }
            }
        }
    }
}
