
function Find-ModuleManifest {
    <#
    .SYNOPSIS
        Find all module manifests in the given directory.
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
        $possibleManifests = Get-ChildItem @PSBoundParameters -Recurse -Filter "*.psd1"

        foreach ($possibleManifest in $possibleManifests) {
            try {
                $module = $possibleManifest | Import-Psd -Unsafe
            } catch {
                Write-Debug "$possibleManifest could not be imported"
                continue
            }
            if ($null -ne $module) {
                Write-Debug "Checking if $($possibleManifest.Name) is a manifest"
                if (
                    ($module.Keys -contains 'ModuleVersion') -and
                    ($module.Keys -contains 'GUID') -and
                    ($module.Keys -contains 'PrivateData')
                ) {
                    $possibleManifest | Write-Output
                } else {
                    Write-Debug "- Not a module manifest file"
                }
            } else {
                continue
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
