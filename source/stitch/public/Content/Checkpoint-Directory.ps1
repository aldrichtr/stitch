
function Checkpoint-Directory {
    <#
    .SYNOPSIS
        Output the relative path and the MD5 hash value of each file in the given Path
    .DESCRIPTION

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingBrokenHashAlgorithms',
        '',
        Justification = 'We are only using MD5 to verify the file has not changed')]
    [OutputType('File.Checksum')]
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
    }
    process {
        if (Test-Path $Path) {
            foreach ($file in (Get-ChildItem -Path $Path -File -Recurse)) {
                $relative = [System.IO.Path]::GetRelativePath((Resolve-Path $Path), $file.FullName)
                $checksum = ($file | Get-FileHash -Algorithm MD5 | Select-Object -ExpandProperty Hash)

                [PSCustomObject]@{
                    PSTypeName = 'File.Checksum'
                    Path       = $relative
                    Hash       = $checksum
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
