
function Checkpoint-File {
    <#
    .SYNOPSIS
        Create a hash of the given file
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingBrokenHashAlgorithms',
        '',
        Justification = 'We are only using MD5 to verify the file has not changed')]
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $hashingAlgorithm = 'MD5'
    }
    process {
        foreach ($file in $Path) {
            $checksum = $file
            | Get-FileHash -Algorithm $hashingAlgorithm
            | Select-Object -ExpandProperty Hash

            [PSCustomObject]@{
                PSTypeName = 'File.Checksum'
                TimeStamp  = Get-Date
                Hash       = $checksum
            }
        }

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
