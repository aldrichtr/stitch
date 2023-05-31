
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
        - The file sourcetypes.config.psd1 in the profile path, the build config path, or this module
        - The `SourceTypeMap` variable
        - The -TypeMap parameter
        Each, if found will update the existing type map
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to a SourceTypeMap file
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # Hash table of mappings to create the new map from
        [Parameter(
        )]
        [hashtable]$TypeMap,

        # Send the object out to the pipeline in addition to setting the script scope variable
        [Parameter(
        )]
        [switch]$PassThru
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        # The name of the Module variable to store the map in once created
        $moduleMapName = 'script:_stitchSourceTypeMap'
        # The variable to look for in the current environment for a map
        $defaultMapVar = 'SourceTypeMap'
        # Used internally to the function to create the map
        $internalMap = @{}

        #-------------------------------------------------------------------------------
        #region file path
        if ($PSBoundParameters.ContainsKey('Path')) {
            if (Test-Path $Path) {
                if ((Get-Item $Path).PSIsContainer) {
                    $defaultMapFile = (Join-Path $Path 'sourcetypes.config.psd1')
                } else {
                    $defaultMapFile = $Path
                }
            }
        } elseif ($null -ne $BuildConfigPath) {
            #! always prefer the Profile's configuration
            $defaultMapFile = (Join-Path $BuildConfigPath 'sourcetypes.config.psd1')
        } elseif ($null -ne $BuildConfigRoot) {
            #! Then the build config directory (.build ?)
            $defaultMapFile = (Join-Path $BuildConfigRoot 'sourcetypes.config.psd1')
        } else {
            #! If those aren't found fall back to the modules internal config
            $defaultMapFile = (join-Path (Get-Item $MyInvocation.MyCommand.Module.Path).Directory 'sourcetypes.config.psd1')
        }
        #endregion file path
        #-------------------------------------------------------------------------------
    }
    process {
        # Load the file
        Write-Debug "Looking for source type map file '$defaultMapFile'"
        if (Test-Path $defaultMapFile) {
            Write-Debug "Updating source type map using '$defaultMapFile'"
            $null = $internalMap = $internalMap | Update-Object (Import-Psd $defaultMapFile)
        }

        # Load the variable
        Write-Debug "Looking for source type map variable '$defaultMapVar'"
        $map = (Get-Variable -Name $defaultMapVar -ValueOnly -ErrorAction SilentlyContinue)
        if ($null -ne $map) {
            Write-Debug "Updating source type map using `$$defaultMapVar"
            $null = $internalMap = $internalMap | Update-Object $map
        }

        # Load the Parameter
        Write-Debug "Looking for source type map Parameter 'TypeMap'"
        if ($PSBoundParameters.ContainsKey('TypeMap')) {
            Write-Debug "Updating source type map using -TypeMap parameter"
            $null = $internalMap = $internalMap | Update-Object $TypeMap
        }

        Write-Debug "Type map created.  Updating `$SourceTypeMap table"
        Set-Variable -Name $moduleMapName -Value $internalMap -Scope 'Script'
        if ($PassThru) {
            $internalMap | Write-Output
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
