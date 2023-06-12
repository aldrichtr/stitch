
function Get-SourceItem {
    <#
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

        # Path to the source type map
        [Parameter(
        )]
        [string]$TypeMap
    )

    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

    process {
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            Write-Debug "No path specified.  Using default source folder"
            $Path = (Join-Path (Resolve-ProjectRoot) 'source')
            Write-Debug "  $Path"
        }
        foreach ($p in $Path) {
            try {
                $item = Get-Item $p -ErrorAction Stop
                if ($item.PSIsContainer) {
                    Get-ChildItem $item.FullName -Recurse:$Recurse |
                    Get-sourceItemInfo -Root $item.FullName | Write-Output
                    continue
                } else {
                    if ($item.Extension -eq '.ps1') {
                        $item | Get-SourceItemInfo | Write-Output
                    }
                    continue

                }
            } catch {
                Write-Warning "$p is not a valid path`n$_"
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
