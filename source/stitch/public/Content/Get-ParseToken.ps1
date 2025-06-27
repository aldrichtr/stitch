
function Get-ParseToken {
    <#
    .SYNOPSIS
        Return an array of Tokens from parsing a file
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
        [string[]]$Path,

        # The type of token to return
        [Parameter(
        )]
        [System.Management.Automation.PSTokenType]$Type
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (Test-Path $Path) {
            $errors = @()
            $content = Get-Item $Path | Get-Content -Raw
            $parsedText = [System.Management.Automation.PSParser]::Tokenize($content, [ref]$errors)

            if ($errors.Count) {
                throw "There were errors parsing $($Path.FullName). $($errors -join "`n")"
            }
            foreach ($token in $parsedText) {
                if ((-not($PSBoundParameters.ContainsKey('Type'))) -or
                    ($token.Type -like $Type)) {
                        $token | Write-Output
                }
            }

        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
