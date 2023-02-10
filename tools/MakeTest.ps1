param(
    [Parameter(
        ValueFromPipeline
    )]
    [PSTypeName('Stitch.SourceItemInfo')][Object[]]$SourceItem,

    [string]$Type = 'Unit',

    [switch]$Force
)

begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    $testTemplate = 'PesterTestTemplate.eps'
    $testOutputDirectory = (Join-Path "tests" $Type)
}
process {
    $testFile = "$($SourceItem.Name).Tests.ps1"
    $testPath = (Join-Path $testOutputDirectory $testFile)

    if ((-not(Test-Path $testPath)) -or ($Force)) {
        Write-Host "Creating test file $testPath" -ForegroundColor Blue
        Invoke-EpsTemplate -Path $testTemplate -Safe -Binding @{ s = $SourceItem } | Set-Content $testPath
    } else {
        Write-Host "$testPath already exists.  Use -Force to overwrite"

    }
}
end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
}
