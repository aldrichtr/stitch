function ConvertFrom-CommentedProperty {
    <#
    .SYNOPSIS
        Uncomment the given Manifest Item
    .DESCRIPTION
        In a typical manifest, unused properties are listed, but commented out with a '#'
        like `# ReleaseNotes = ''`
        Update-Metadata, Import-Psd and similar functions need to have these fields available.
        `ConvertFrom-CommentedProperty` will remove the '#' from the line so that those functions can use the given
        property
    .EXAMPLE
        $manifest | ConvertFrom-CommentedProperty 'ReleaseNotes'
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # The item to uncomment
        [Parameter(
            Position = 0
        )]
        [Alias('PropertyName')]
        [string]$Property
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if ($PSBoundParameters.ContainsKey('Path')) {
            if (Test-Path $Path) {
                $commentToken = $Path | Find-ParseToken -Type Comment -Pattern "^\s*#\s*$Property\s+=.*$" | Select-Object -First 1
                if ($null -ne $commentToken) {
                    $replacementIndent = (' ' * ($commentToken.StartColumn - 1))
                    $newContent = $commentToken.Content -replace '#\s*', $replacementIndent
                    $fileContent = @(Get-Content $Path)
                    $fileContent[$commentToken.StartLine - 1] = $newContent
                    $fileContent | Set-Content $Path

                } else {
                    # if we did not find the comment, signal that it was not successful
                    Write-Warning "$Property comment not found"
                }
            } else {
                throw "$Path is not a valid path"
            }
        }

        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
