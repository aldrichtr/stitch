function Get-SourceFilePath {
    [CmdletBinding()]
    param(
        # The test file to get the source file for
        [Parameter(
        )]
        [string]$TestFile
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        <#
        we want to go from
        'tests/Unit/module1/public/Get-TheThing.Tests.ps1' to
        'source/module1/public/Get-TheThing.ps1'
        #>
        $sourceFile = $TestFile -replace '\.Tests\.ps1', '.ps1'
        $sourceFile = $sourceFile -replace '[uU]nit[\\\/]', ''
        $sourceFile = $sourceFile -replace 'tests' , 'source'
    }
    end {
        $sourceFile
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function Get-TestDataPath {
    <#
    .SYNOPSIS
        Return the data directory associated with the test
    #>
    [CmdletBinding()]
    param(
        # The test file to get the data directory for
        [Parameter(
        )]
        [string]$TestFile
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $testFileItem = Get-Item $TestFile
        $currentDirectory = $testFileItem.Directory
        $commandName = $testFileItem.BaseName -replace '\.Tests', ''
        $dataDirectory = (Join-Path $currentDirectory "$commandName.Data")
    }
    end {
        $dataDirectory
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
