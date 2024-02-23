
function Convert-HelpToExternalFile {
    <#
    .SYNOPSIS
        Remove the Comment-based help section from the file and replace with a .EXTERNALHELPFILE line
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more files with a function defined.
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # The name of the external file
        [Parameter(
        )]
        [string]$HelpFile

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $keywords = @('.SYNOPSIS', '.DESCRIPTION', '.EXAMPLE', '.NOTES')
    }
    process {
        foreach ($file in $Path) {
            if ($file | Test-Path) {
                try {
                    #TODO: Get the tokens of the file, replace the help comment token
                }
                catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
