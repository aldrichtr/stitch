
function Find-TestDirectory {
    <#
    .SYNOPSIS
        Find the directory where tests are stored
    #>
    [CmdletBinding()]
    param(
        # Test file pattern
        [Parameter(
        )]
        [string]$TestsPattern = '*.Tests.ps1'
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $root = Resolve-ProjectRoot
        Write-Debug "Looking for test directory in $root"

        $testFiles = Find-TestFile $root -TestsPattern $TestsPattern
        $foundDirectories = [System.Collections.ArrayList]::new()

        if ($testFiles.Count -gt 0) {
            :testfile foreach ($testFile in $testFiles) {
                $relativePath = [System.IO.Path]::GetRelativePath($root, $testFile.FullName)
                $parts = $relativePath -split [regex]::Escape([System.IO.Path]::DirectorySeparatorChar)
                Write-Debug "$($testFile.FullName) is $($parts.Count) levels below root"
                :parts switch ($parts.Count) {
                    0 {
                        throw "The path to $($testFile.FullName) is invalid"
                    }
                    default {
                        $possibleTestPath = (Join-Path $root $parts[0])
                        if ($possibleTestPath -notin $foundDirectories) {
                            [void]$foundDirectories.Add($possibleTestPath)
                            continue testfile
                        }
                    }
                }
            }
        }
    }
    end {
        $foundDirectories | Foreach-Object { Get-Item $_ | Write-Output }
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
