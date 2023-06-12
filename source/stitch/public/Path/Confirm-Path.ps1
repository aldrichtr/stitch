
function Confirm-Path {
    <#
    .SYNOPSIS
        Tests if the directory exists and if it does not, creates it.
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        # The path to confirm
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # The type of item to confirm
        [Parameter(
        )]
        [ValidateSet('Directory', 'File', 'SymbolicLink', 'Junction', 'HardLink')]
        [string]$ItemType = 'Directory'
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if (Test-Path $Path) {
            Write-Debug "Path exists"
            $true
        } else {
            try {
                Write-Debug "Checking if the directory exists"
                $directory = $Path | Split-Path -Parent
                if (Test-Path $directory) {
                    Write-Debug "  - The directory $directory exists"
                } else {
                    $null = New-Item $directory -Force -ItemType Directory
                }
                Write-Debug "Creating $ItemType $Path"
                $null = New-Item -Path $Path -ItemType $ItemType -Force
                Write-Debug "Now confirming $Path exists"
                if (Test-Path $Path) {
                    $true
                } else {
                    $false
                }
            }
            catch {
                throw "There was an error confirming $Path`n$_"
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
