
function Invoke-ReplaceToken {
    <#
    .SYNOPSIS
        Replace a given string 'Token' with another string in a given file.
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'medium'
    )]
    param(

        # File(s) to replace tokens in
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath', 'Path')]
        [string]$In,

        # The token to replace, written as a regular-expression
        [Parameter(
            Position = 0,
            Mandatory
        )]
        [string]$Token,

        # The value to replace the token with
        [Parameter(
            Position = 1,
            Mandatory
        )]
        [Alias('Value')]
        [string]$With,


        # The destination file to write the new content to
        # If destination is a directory, `Invoke-ReplaceToken` will put the content in a file named the same as
        # the input, but in the given directory
        [Parameter(
            Position = 2
            )]
            [Alias('Out')]
            [string]$Destination
    )
    begin {
    }
    process {
        try {
            $content = Get-Content $In -Raw
            if ($content | Select-String -Pattern $Token) {
                Write-Debug "Token $Token found, replacing with $With"
                $newContent = ($content -replace [regex]::Escape($Token), $With)

                if ($PSBoundParameters.ContainsKey('Destination')) {
                    $destObject = Get-Item $Destination
                    if ($destObject -is [System.IO.FileInfo]) {
                        $destFile = $Destination
                    } elseif ($destObject -is [System.IO.DirectoryInfo]) {
                        $destFile = (Join-Path $Destination ((Get-Item $file).Name))
                    } else {
                        throw "$Destination should be a file or directory"
                    }
                } else {
                    $newContent | Write-Output
                }
                if ($PSCmdlet.ShouldProcess($destFile, "Replace $Token with $With")) {
                    Write-Verbose "Writing output to $destFile"
                    $newContent | Set-Content $destFile -Encoding utf8NoBOM
                }
            } else {
                #! This is a little rude, but I have to find a way to let the user know that nothing changed,
                #! and I don't want to send anything out to the console in case it is being directed somewhere
                #TODO: Consider using Write-Warning
                $save_verbose = $VerbosePreference
                $VerbosePreference = 'Continue'
                Write-Verbose "$Token not found in $In"
                $VerbosePreference = $save_verbose
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    end {
    }
}
