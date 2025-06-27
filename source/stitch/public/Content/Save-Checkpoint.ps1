
function Save-Checkpoint {
    <#
    .SYNOPSIS
        Store the relative path and MD5 sum of file(s) in path to the file in CSV format
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations to compute the checksum (MD5 hashes) for
        [Parameter(
        Position = 1,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # The file that will contain the checksums (CSV format)
        [Parameter(
            Position = 0
        )]
        [string]$ChecksumFile = ".checksum.csv",

        # Force the overwrite of an existing Checksum file
        [Parameter(
        )]
        [switch]$Force

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (Test-Path $ChecksumFile) {
            if ($Force) {
                Clear-Content $ChecksumFile
            } else {
                throw "$ChecksumFile already exists.  Use -Force to overwrite"
            }
        }
        $path | Checkpoint-Directory | EXport-Csv $ChecksumFile
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
