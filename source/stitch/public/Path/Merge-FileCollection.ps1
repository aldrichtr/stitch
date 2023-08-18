function Merge-FileCollection {
    <#
    .SYNOPSIS
        Merge an array of files into an existing collection, overwritting any that have the same basename
    .NOTES
        The collection is passed in by reference.  This is so that the collection is updated without having to
        reapply the result.
    .EXAMPLE
        $updates | Merge-FileCollection [ref]$allFiles
    .EXAMPLE
        Get-ChildItem -Path . -Filter *.ps1 | Merge-FileCollection [ref]$allScripts
    #>
    [CmdletBinding()]
    param(
        # The collection of files to merge the updates into
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [AllowEmptyCollection()]
        [ref]$Collection,

        # The additional files to update the collection with
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline
        )]
        [Array]$UpdateFiles

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        foreach ($currentUpdateFile in $UpdateFiles) {
            <#
             if this file name exists in the Collection array, we remove it from the collection
             and add this file,  otherwise just add the file
            #>
            $baseNames = $Collection.Value | Select-Object -ExpandProperty BaseName
            if ($baseNames -contains $currentUpdateFile.BaseName ) {
                $previousTaskFile = $Collection.Value | Where-Object {
                    $_.BaseName -like $currentUpdateFile.BaseName
                }
                if ($null -ne $previousTaskFile) {
                    Write-Verbose "Overriding $($currentUpdateFile.BaseName)"
                    $index = $Collection.Value.IndexOf( $previousTaskFile )
                    $Collection.Value[$index] = $currentUpdateFile
                }
            } else {
                $Collection.Value += $currentUpdateFile
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
