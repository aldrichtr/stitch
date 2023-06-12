param(
    [Parameter(
        ValueFromPipeline
    )]
    [PSTypeName('Stitch.SourceItemInfo')][Object[]]$SourceItem,

    [string]$SourceDir = 'source',

    [string]$TestsDir = 'tests',

    [string]$Type = 'Unit',

    [switch]$Force,

    [switch]$ToHost,

    [switch]$Open
)

begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
}
process {
    $testTemplate = "$PSScriptRoot\PesterTestTemplate.$Type.eps"

    Write-Host "Creating Test for $($SourceItem.Name) using $testTemplate" -ForegroundColor Blue
    $relativeSourceDirectory = Resolve-Path $SourceItem.Path -Relative

    Write-Host "Source directory is $relativeSourceDirectory" -Foreground DarkGray
    $testOutputDirectory = ($relativeSourceDirectory -replace $SourceDir , $TestsDir) | Split-Path
    if (-not(Test-Path $testOutputDirectory)) {
        Write-Host "$testOutputDirectory does not exist.  Creating test directory" -ForegroundColor Blue
        try {
            New-Item $testOutputDirectory -ItemType Directory -Force
        } catch {
            throw "Could not create required test directory '$testOutputDirectory'`n$_"
        }
    }
    $testFile = "$($SourceItem.Name).Tests.ps1"
    $testPath = (Join-Path $testOutputDirectory $testFile)

    try {
        $content = Invoke-EpsTemplate -Path $testTemplate -Safe -Binding @{ s = $SourceItem }
    } catch {
        throw "There was an error in the template`n$_"
    }

    if ($ToHost) {
        $content | Write-Output
    } else {
        if ((-not(Test-Path $testPath)) -or ($Force)) {
            if ($content.Length -gt 0) {
                Write-Host "Creating $Type test file '$testPath'" -ForegroundColor Blue
                $content | Set-Content $testPath -Encoding utf8NoBOM
            } else {
                throw 'Template did not produce any output'
            }

            if ($Open) { code -r $testPath }

        } else {
            Write-Host "$testPath already exists.  Use -Force to overwrite"
        }
    }
}
end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
}
