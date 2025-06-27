function Merge-BuildConfiguration {
    [CmdletBinding()]
    param(
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
            [string]$Key,

            # Specifies a path to one or more configuration files
            [Parameter(
            Position = 2,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
            )]
            [Alias('PSPath')]
            [string[]]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        foreach ($file in $Path) {
            $options = Convert-ConfigurationFile $Path

            if ($null -ne $options) {
                if ($PSBoundParameters.ContainsKey('Key')) {
                    $Object.Value.$Key | Update-Object -UpdateObject $options
                } else {
                    $Object.Value | Update-Object -UpdateObject $options
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
