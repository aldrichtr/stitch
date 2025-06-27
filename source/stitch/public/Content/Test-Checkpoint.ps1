
function Test-Checkpoint {
    <#
    .SYNOPSIS
        Compares the checkpoint of a file to its current hash
    .DESCRIPTION
        Compare the MD5 hash to the HASH given.  Returns true if they are equal, false if not
    .EXAMPLE
        $file | Test-Checkpoint "C72CD5EBFDC6D41E2A9F539AA94F2E8A"
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingBrokenHashAlgorithms',
        '',
        Justification = 'We are only using MD5 to verify the file has not changed')]

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

        # The md5 hash to compare to
        [Parameter(
            Position = 0,
            Mandatory
        )]
        [string]$Hash
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $item = Get-Item $Path

        if ($item.PSIsContainer) {
            throw "Can only compare files not directories"
        }

        $currentHash = $Path | Get-FileHash -Algorithm MD5 | Select-Object -ExpandProperty Hash

        #! return true or false based on if the hash has changed
        ($Hash -eq $currentHash) | Write-Output
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
