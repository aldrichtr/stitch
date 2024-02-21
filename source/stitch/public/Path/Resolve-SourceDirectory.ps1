
function Resolve-SourceDirectory {
    <#
    .SYNOPSIS
        Resolve the directory that contains the project's source files
    #>
    [CmdletBinding()]
    param(
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $ignoredDirectories = @('.build', '.stitch')
        $maximumNestedLevel = 4
    }
    process {
        $root = Resolve-ProjectRoot
        $sourceDirectory = $null
        Write-Debug "Looking for source directory in $root"

        $manifests = Find-ModuleManifest $root

        if ($manifests.Count -gt 0) {
            :manifest foreach ($manifest in $manifests) {
                $relativePath = [System.IO.Path]::GetRelativePath($root, $manifest.FullName)
                $parts = $relativePath -split [regex]::Escape([System.IO.Path]::DirectorySeparatorChar)
                Write-Debug "$($manifest.FullName) is $($parts.Count) levels below root"
                :parts switch ($parts.Count) {
                    0 {
                        throw "The path to $($manifest.FullName) is invalid"
                    }
                    default {
                        if ($parts[0] -notin $ignoredDirectories) {
                            if ($parts.Count -lt $maximumNestedLevel ) {
                                $possibleSourceDirectory = Get-Item (Join-Path $root $parts[0])
                                if ($null -eq $sourceDirectory) {
                                    $sourceDirectory = $possibleSourceDirectory
                                } else {
                                    if ($possibleSourceDirectory.FullName -eq $sourceDirectory.FullName) {
                                        Write-Debug "$($possibleSourceDirectory.Name) already set"
                                    }
                                }
                            } else {
                                Write-Debug "$($manifest.Name) is nested below maximum levels: $($parts.Count)"
                            }
                        } else {
                            Write-Debug "$($parts[0]) is ignored"
                        }
                        continue manifest
                    }
                }
            }
        } else {
            throw "No manifests found in project '$root'"
        }
        $sourceDirectory
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
