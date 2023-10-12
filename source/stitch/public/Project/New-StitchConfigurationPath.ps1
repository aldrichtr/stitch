function New-StitchConfigurationPath {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
        Position = 1,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # The name of the directory.  Supports '.build' or '.stitch'
        [Parameter(
        )]
        [ValidateSet('.build', '.stitch')]
        [string]$Name = '.build'
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('Path'))) {
            $Path = Get-Location
        }
        $buildConfigDir = (Join-Path $Path $Name)
        Write-Debug 'Create directories if they do not exist'
        Write-Debug "  - Looking for $buildConfigDir"
        if (-not(Test-Path $buildConfigDir)) {
            try {
                '{0} does not exist.  {1}Creating{2}' -f $buildConfigDir, $PSStyle.Foreground.Green, $PSStyle.Reset
                $null = mkdir $buildConfigDir -Force
            } catch {
                throw "Could not create Build config directory $BuildConfigDir`n$_"
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
