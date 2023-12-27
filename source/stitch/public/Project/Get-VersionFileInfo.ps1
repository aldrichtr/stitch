
function Get-VersionFileInfo {
    <#
    .SYNOPSIS
        Return version info stored in a file in the project
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('Path'))) {
            $Path = Resolve-ProjectRoot
        }
        Write-Debug '  - Looking for version.* file'
        $found = Get-ChildItem -Path $Path -Filter 'version.*' -Recurse |
            Sort-Object LastWriteTime |
                Select-Object -Last 1

        if ($null -ne $found) {
            Write-Verbose "Using $found for version info"
            Write-Debug "    - Found $($found.FullName)"
            switch -Regex ($found.extension) {
                'psd1' { $versionInfo = Import-Psd $found }
                'json' { $versionInfo = (Get-Content $found | ConvertFrom-Json) }
                'y(a)?ml' { $versionInfo = (Get-Content $found | ConvertFrom-Yaml) }
                Default { Write-Information "$($found.Name) found but no converter for $($found.extension) is set" }
            }
            $versionInfo['PSTypeName'] = 'Stitch.VersionInfo'
            [PSCustomObject]$versionInfo | Write-Output
        } else {
            throw "Could not find version file in $Path"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
