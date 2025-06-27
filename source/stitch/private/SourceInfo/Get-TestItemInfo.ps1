
function Get-TestItemInfo {
    [CmdletBinding()]
    param(
        # The directory to look in for source files
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        # The root directory to use for test properties
        [Parameter(
        )]
        [string]$Root
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        foreach ($p in $Path) {
            Write-Debug "Processing $p"
            #-------------------------------------------------------------------------------
            #region File selection

            $fileItem = Get-Item $p -ErrorAction Stop

            if ($fileItem.Extension -notlike '.ps1') {
                Write-Verbose "Not adding $($fileItem.Name) because it is not a .ps1 file"
                continue
            } else {
                Write-Debug "$($fileItem.Name) is a test item"
            }
            #endregion File selection
            #-------------------------------------------------------------------------------

            #-------------------------------------------------------------------------------
            #region Object creation
            $pesterConfig = New-PesterConfiguration
            $pesterConfig.Run.Path = $p.FullName
            $pesterConfig.Run.SkipRun = $true
            $pesterConfig.Run.PassThru = $true
            $pesterConfig.Output.Verbosity = 'None' # Quiet
            try {
                $testResult = Invoke-Pester -Configuration $pesterConfig
                Write-Debug "Root is $Root"
            } catch {
                throw "Could not load test item $Path`n$_ "
            }
            $testInfo = @{
                PSTypeName = 'Stitch.TestItemInfo'
                Tests = $testResult.Tests
                Path = $p.FullName
            }

            [PSCustomObject]$testInfo | Write-Output
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
