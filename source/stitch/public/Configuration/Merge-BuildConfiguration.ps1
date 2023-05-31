function Merge-BuildConfiguration {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more configuration files
        [Parameter(
        Position = 2,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # The object to merge the configuration into (by reference)
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [ref]$Object,

        # The top level key in which to add the given table
        [Parameter(
            Position = 1
        )]
        [string]$Key
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        foreach ($file in $Path) {
            $options = Convert-ConfigurationFile $Path
            if ($null -ne $options) {
                $Object.Value | Update-Object -UpdateObject $options
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
