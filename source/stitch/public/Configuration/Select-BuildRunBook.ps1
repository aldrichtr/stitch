
function Select-BuildRunBook {
    <#
    .SYNOPSIS
        Locate the runbook for the given BuildProfile
    .DESCRIPTION
        Select-BuildRunBook locates the runbook associated with the BuildProfile.  If no BuildProfile is given,
        Select-BuildRunBook will use default names to search for
    .EXAMPLE
        $ProfilePath | Select-BuildRunBook 'default'
        $ProfilePath | Select-BuildRunBook 'site'
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
            )]
            [Alias('PSPath')]
            [string[]]$Path,

        # The build profile to select the runbook for
        [Parameter(
            Position = 0
        )]
        [string]$BuildProfile
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $defaultProfileNames = @(
            'default',
            'build'
        )
        $defaultRunbookSuffix = "runbook.ps1"
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('Path'))) {
            if (-not ([string]::IsNullorEmpty($PSCmdlet.GetVariableValue('ProfileRoot')))) {
                $Path = $PSCmdlet.GetVariableValue('ProfileRoot')
            } else {
                $Path = (Get-Location).Path
            }
        }

        if (-not ($PSBoundParameters.ContainsKey('BuildProfile'))) {
            $searches = $defaultProfileNames
        } else {
            $searches = $BuildProfile
        }

        foreach ($p in $Path) {
            if (Test-Path $p) {
                foreach ($searchFor in $searches) {
                    Write-Debug "Looking in $p for $searchFor runbook"
                    <#
                    First, look for the buildprofile.runbook.ps1 in the given directory
                    #>
                    $options = @{
                        Path = $p
                        Filter = "$searchFor.$defaultRunbookSuffix"
                    }
                    $possibleRunbook = Get-ChildItem @options | Select-Object -First 1

                    if ($null -eq $possibleRunbook) {
                        Write-Debug " - No runbook found in $p matching $($options.Filter)"
                        $null = $options.Clear()
                        $options = @{
                            Path = (Join-Path $p $searchFor)
                            Filter = "*$defaultRunbookSuffix"
                        }
                        Write-Debug "Looking in $($options.Path) using $($options.Filter)"
                        if (Test-Path $options.Path) {
                            $possibleRunbook = Get-ChildItem @options | Select-Object -First 1
                        }
                    }

                    if ($null -ne $possibleRunbook) {
                        $possibleRunbook | Write-Output
                    }
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
