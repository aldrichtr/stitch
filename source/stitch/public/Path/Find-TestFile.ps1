
function Find-TestFile {
    <#
    .SYNOPSIS
        Find files that contain tests
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
        [string[]]$Path,

        # Test file pattern
        [Parameter(
        )]
        [string]$TestsPattern = '*.Tests.ps1'
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $possibleTestFiles = Get-ChildItem -Path $Path -Recurse -File -Filter $TestsPattern

        foreach ($possibleTestFile in $possibleTestFiles) {
            Write-Debug "Checking $possibleTestFile for Pester tests"
            if ($possibleTestFile | Select-String '\s*Describe') {
                Write-Debug "- Has the 'Describe' keyword"
                $possibleTestFile | Write-Output
            } else {
                continue
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
