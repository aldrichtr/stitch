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
        [string]$Root,

        # Optionally run the testes
        [Parameter(
        )]
        [switch]$RunTest

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
                #TODO: Are there other extensions we should look for ?
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
                Write-Debug "  Creating item $($fileItem.BaseName) from $($fileItem.FullName)"
                $pesterConfig = New-PesterConfiguration
                $pesterConfig.Run.PassThru = $true
                $pesterConfig.Run.SkipRun = (-not ($RunTest))
                try {
                    $pesterContainer = New-PesterContainer -Path:$p
                    $pesterConfig.Run.Container = $pesterContainer
                    $testResult = Invoke-Pester -Configuration $pesterConfig
                    Write-Debug "Root is $Root"
                } catch {
                    throw "Could not load test item $Path`n$_ "
                }
            }
            }
            end {
                $testResult
                Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
            }

        }
