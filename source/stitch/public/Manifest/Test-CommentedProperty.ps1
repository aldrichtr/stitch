function Test-CommentedProperty {
    <#
    .SYNOPSIS
        Test if the given property is commented in the given manifest
    .EXAMPLE
        $manifest | Test-CommentedProperty 'ReleaseNotes'
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # The item to uncomment
        [Parameter(
            Position = 0
        )]
        [Alias('PropertyName')]
        [string]$Property

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if ($PSBoundParameters.ContainsKey('Path')) {
            if (Test-Path $Path) {
                $commentToken = $Path | Find-ParseToken -Type Comment -Pattern "^\s*#\s*$Property\s+=.*$" | Select-Object -First 1
                $null -ne $commentToken | Write-Output
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
