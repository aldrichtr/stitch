
function Test-WindowsLineEnding {
    <#
    .SYNOPSIS
        Test for "Windows Line Endings" (CRLF) in the given file
    .DESCRIPTION
        `Test-WindowsLineEnding` returns true if the file contains CRLF endings, and false if not
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (Test-Path $Path) {
            (Get-Content $Path -Raw) -match '\r\n$'
        } else {
            Write-Error "$Path could not be found"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
