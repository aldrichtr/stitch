
Function Get-SourceItem {
    <#
    #>
    [OutputType('BuildTool.SourceItem')]
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
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            Write-Debug "No path specified.  Using default source folder"
            $Path = (Join-Path (Resolve-ProjectRoot) 'source')
            Write-Debug "  $Path"
        }
        foreach ($p in $Path) {
            try {
                $item = Get-Item $p -ErrorAction Stop
                switch (($item.GetType()).Name) {
                    'FileInfo' {
                        if ($item.Extension -eq '.ps1') {
                            Get-SourceItemInfo -Root $Root | Write-Output
                        }
                        continue
                    }
                    'DirectoryInfo' {
                        Get-ChildItem $item.FullName -Recurse:$Recurse |
                        Get-sourceItemInfo -Root $item.FullName | Write-Output
                        continue
                    }
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
