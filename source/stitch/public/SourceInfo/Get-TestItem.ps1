function Get-TestItem {
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
            Write-Debug "No path specified.  Looking for `$Tests"
            $testsVariable = $PSCmdlet.GetVariableValue('Tests')
            if ($null -ne $testsVariable) {
                Write-Debug "  - found `$Tests: $testsVariable"
            } else {
                Write-Debug 'Checking for default tests folder'
                $possiblePath = (Join-Path (Resolve-ProjectRoot) 'tests')
                if ($null -ne $possiblePath) {
                    if (Test-Path $possiblePath) {
                        $Path = $possiblePath
                    }
                }
            }
            if ($null -eq $Path) {
                throw 'Could not resolve a Path to tests'
            } else {
                Write-Debug "Path is $Path"
            }
        }

        foreach ($p in $Path) {
            try {
                $item = Get-Item $p -ErrorAction Stop
            } catch {
                Write-Warning "$p is not a valid path`n$_"
                continue
            }
            if ($item.PSIsContainer) {
                try {
                    Get-ChildItem $item.FullName -Recurse:$Recurse -File |
                        Get-TestItemInfo -Root $item.FullName | Write-Output
                }
                catch {
                    Write-Warning "$_"
                }
                continue
            } else {
                if ($item.Extension -eq '.ps1') {
                    try {
                        $item | Get-TestItemtInfo | Write-Output
                    }
                    catch {
                        Write-Warning "$_"
                    }
                    continue
                }
                continue
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
