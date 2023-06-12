
function Find-ParseToken {
    <#
    .SYNOPSIS
        Return an array of tokens that match the given pattern
    #>
    [OutputType([System.Array])]
    [CmdletBinding()]
    param(
        # The token to find, as a regex
        [Parameter(
            Position = 0
        )]
        [string]$Pattern,

        # The type of token to look in
        [Parameter(
            Position = 1
        )]
        [System.Management.Automation.PSTokenType]$Type,

        # Specifies a path to one or more locations.
        [Parameter(
        Position = 2,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $options = $PSBoundParameters
        $null = $options.Remove('Pattern')
        try {
            $tokens = Get-ParseToken @options
        }
        catch {
            throw "Could not parse $Path`n$_"
        }

        if ($null -ne $tokens) {
            Write-Debug "  - Looking for $Pattern in $($tokens.Count) tokens"
            foreach ($token in $tokens) {
                Write-Debug "    - Checking $($token.Content)"
                if ($token.Content -Match $Pattern) {
                    $token | Write-Output

                }
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
