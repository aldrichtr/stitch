$source_directories = @(
    'enum',
    'classes',
    'private',
    'public'
)

$import_options = @{
    Path        = $PSScriptRoot
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'Stop'
}

$prefixFile = (Join-Path $PSScriptRoot 'prefix.ps1')
$suffixFile = (Join-Path $PSScriptRoot 'suffix.ps1')

if (Test-Path $prefixFile) { . $prefixFile }

if (Test-Path "$PSScriptRoot\LoadOrder.txt") {
    Write-Host 'Using custom load order'
    $custom = Get-Content "$PSScriptRoot\LoadOrder.txt"
    Get-ChildItem @import_options -Recurse | ForEach-Object {
        $rel = $_.FullName -replace [regex]::Escape("$PSScriptRoot\") , ''
        if ($rel -notin $custom) {
            Write-Warning "$rel is not listed in custom"
        }
    }
    try {
        Get-Content "$PSScriptRoot\LoadOrder.txt" | ForEach-Object {
            switch -Regex ($_) {
                '^\s*$' {
                    # blank line, skip
                    continue
                }
                '^\s*#$' {
                    # Comment line, skip
                    continue
                }
                '^.*\.ps1' {
                    # load these
                    . "$PSScriptRoot\$_"
                    continue
                }
                default {
                    #unrecognized, skip
                    continue
                }
            }
        }
    } catch {
        Write-Error "Custom load order $_"
    }
} else {
    try {
        foreach ($dir in $source_directories) {
            $import_options.Path = (Join-Path $PSScriptRoot $dir)

            Get-ChildItem @import_options | ForEach-Object {
                $currentFile = $_.FullName
                . $currentFile
            }
        }
    } catch {
        throw "An error occured during the dot-sourcing of module .ps1 file '$currentFile':`n$_"
    }
}

if (Test-Path "$PSScriptRoot\formats") {
    Get-ChildItem "$PSScriptRoot\formats" -Filter '*.Format.ps1xml'
    | ForEach-Object { Update-FormatData -AppendPath $_ }
}

if (Test-Path $suffixFile) { . $suffixFile }

$formatDirectory = (Join-Path $PSScriptRoot 'formats')

if (Test-Path $formatDirectory) {
    foreach ($format in (Get-ChildItem $formatDirectory -Filter "*.ps1xml")) {
        Update-FormatData -AppendPath $format.FullName -ErrorAction SilentlyContinue
    }
}
