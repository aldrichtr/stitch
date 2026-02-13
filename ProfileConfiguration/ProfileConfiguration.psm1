$private:templateInfo = {
    ConvertFrom-StringData -StringData @'
        Name = "Source module template"
        Version = "0.7.0"
        Modified = "2024-01-31 17:58:56"
'@
}

#! if debug was turned on, we need to see it and pass it into this scope
if ($global:DebugPreference -like 'Continue') {
    $script:DebugPreference = 'Continue'
}

<#
This module file is intended to be used during development to load all of the
files in the directories in this module folder
#>

$private:modulePath = $PSCommandPath
$private:moduleName = ($private:modulePath | Split-Path -Leaf)

Write-Debug "Loading $private:moduleName from $private:modulePath"
Write-Debug "-- Using $($private:templateInfo.Name) $($private:templateInfo.Version)"

$private:sourceDirectories = @(
    'enum',
    'classes',
    'private',
    'public'
)

$private:formatsOptions = @{
    Path    = (Join-Path $PSScriptRoot 'formats')
    Filter  = '*.Formats.ps1xml'
    Recurse = $true
}

$private:typesOptions = @{
    Path    = (Join-Path $PSScriptRoot 'types')
    Filter  = '*.Types.ps1xml'
    Recurse = $true
}

$private:prefixFile = (Join-Path $PSScriptRoot 'prefix.ps1')
$private:suffixFile = (Join-Path $PSScriptRoot 'suffix.ps1')

$private:importOptions = @{
    Path        = $PSScriptRoot
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'Stop'
}

if ($private:prefixFile | Test-Path) {
    Write-Debug "Loading prefix file $private:prefixFile"
    . $private:prefixFile
}

if (Test-Path "$PSScriptRoot\LoadOrder.txt") {
    Write-Host 'Using custom load order'
    $private:custom = Get-Content "$PSScriptRoot\LoadOrder.txt"
    Get-ChildItem @$private:importOptions -Recurse
    | ForEach-Object {
        $private:relativePath = [System.IO.Path]::GetRelativePath( $PSScriptRoot , $_)
        if ($private:relativePath -notin $custom) {
            Write-Warning "$private:relativePath is not listed in custom"
        }
    }
    try {
        Get-Content "$PSScriptRoot\LoadOrder.txt"
        | ForEach-Object {
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
        foreach ($private:directory in $private:sourceDirectories) {
            $private:importOptions.Path = (Join-Path $PSScriptRoot $private:directory)

            Get-ChildItem @private:importOptions
            | ForEach-Object {
                $private:currentFile = $_.FullName
                Write-Debug "Loading $private:currentFile"
                . $currentFile
            }
        }
    } catch {
        throw "An error occured during the dot-sourcing of module .ps1 file '$currentFile':`n$_"
    }

}

if ($private:formatsOptions.Path | Test-Path) {
    foreach ($private:formatFile in (Get-ChildItem @private:formatsOptions)) {
        Write-Debug "Adding Formats from $($private:formatFile.Name)"
        Update-FormatData -AppendPath $private:formatFile.FullName
    }
}

if ($private:typesOptions.Path | Test-Path) {
    foreach ($private:typeFile in (Get-ChildItem @private:typesOptions)) {
        Write-Debug "Adding types from $($private:typeFile.Name)"
        Update-TypeData -AppendPath $private:typeFile
    }
}

if ($private:suffixFile | Test-Path) {
    Write-Debug "Loading suffix file $private:suffixFile"
    . $private:suffixFile
}
