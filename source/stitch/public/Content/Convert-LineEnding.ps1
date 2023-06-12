
function Convert-LineEnding {
    <#
    .SYNOPSIS
        Convert the line endings in the given file to "Windows" (CRLF) or "Unix" (LF)
    .DESCRIPTION
        `Convert-LineEnding` will convert all of the line endings in the given file to the type specified.  If
        'Windows' or 'CRLF' is given, all line endings will be '\r\n' and if 'Unix' or 'LF' is given all line
        endings will be '\n'

        'Unix' (LF) is the default
    .EXAMPLE
        Get-ChildItem . -Filter "*.txt" | Convert-LineEnding -LF

        Convert all txt files in the current directory to '\n'
    .NOTES
        WARNING! this can corrupt a binary file.
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Unix'
    )]
    param(
        # The file to be converted
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # Convert line endings to 'Unix' (LF)
        [Parameter(
            ParameterSetName = 'Unix',
            Position = 1
        )]
        [switch]$LF,

        # Convert line endings to 'Windows' (CRLF)
        [Parameter(
            ParameterSetName = 'Windows',
            Position = 1
        )]
        [switch]$CRLF
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        foreach ($file in $Path) {
            if ($CRLF) {
                Write-Verbose "  Converting line endings in $($file.Name) to 'CRLF'"
            ((Get-Content $file) -join "`r`n") | Set-Content -NoNewline -Path $file
            } elseif ($LF) {
                Write-Verbose "  Converting line endings in $($file.Name) to 'LF'"
            ((Get-Content $file) -join "`n") | Set-Content -NoNewline -Path $file
            } else {
                Write-Error "No EOL format specified.  Please use '-LF' or '-CRLF'"
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

