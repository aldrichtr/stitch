
function New-SourceTypeMap {
    <#
    .SYNOPSIS
        Create a new mapping table of source items to their Visibility and Type
    .DESCRIPTION
        The source type map is used by `Get-SourceItemInfo` to set the Visibility and Type attribute on items found
        in the module source directories.
        `Visibility` and `Type` is used to determine if the item should be included in the module manifest `Export`
        keys (for example, if `Type` is `function` and `Visibility` is `public`, the item is listed in
        `FunctionsToExport`, etc.)

        `New-SourceTypeMap` looks in the following locations for data to populate the map:
        - The file .build/config/sourcetypes.config.psd1
        - The `SourceTypeMap` variable
        - The -TypeMap parameter
        Each, if found will update the existing type map
    #>
    [CmdletBinding()]
    param(
        # Hash table of mappings to create the new map from
        [Parameter(
        )]
        [hashtable]$TypeMap
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $DEFAULT_MAP_VAR = 'SourceTypeMap'
        $DEFAULT_MAP_FILE = '.\.build\config\sourcetypes.config.psd1'
        $internalMap = @{}
    }
    process {
        if (Test-Path $DEFAULT_MAP_FILE) {
            Write-Debug "Updating source type map using '$DEFAULT_MAP_FILE'"
            $null = $internalMap = $internalMap | Update-Object (Import-Psd $DEFAULT_MAP_FILE)
        }

        $map = (Get-Variable -Name $DEFAULT_MAP_VAR -ValueOnly -ErrorAction SilentlyContinue)
        if ($null -ne $map) {
            Write-Debug "Updating source type map using `$$DEFAULT_MAP_VAR"
            $null = $internalMap = $internalMap | Update-Object $map
        }

        if ($PSBoundParameters.ContainsKey('TypeMap')) {
            Write-Debug "Updating source type map using -TypeMap parameter"
            $null = $internalMap = $internalMap | Update-Object $TypeMap
        }
        Write-Debug "Type map created.  Updating `$SourceTypeMap table"
        Set-Variable -Name $DEFAULT_MAP_VAR -Value $internalMap -Scope 'Script'
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
