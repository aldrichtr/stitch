
using namespace System.Management.Automation.Language

function Get-SourceItemInfo {
    [CmdletBinding()]
    param(
        # The directory to look in for source files
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        # The root directory of the source item, using the convention of a
        # source folder with one or more module folders in it.
        # Should be the Module's Source folder of your project
        [Parameter(
        )]
        [string]$Root

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        try {
            # sets $script:SourceTypeMap
            $sourceTypeMap = Get-SourceTypeMap
        }
        catch {
            throw "Could not find map for source types`n$_"
        }
    }
    process {
        foreach ($p in $Path) {
            Write-Debug "Processing $p"
            try {
                #-------------------------------------------------------------------------------
                #region File selection

                $fileItem = Get-Item $p -ErrorAction Stop
                if ($fileItem.Extension -notlike '.ps1') {
                    Write-Verbose "Not adding $($fileItem.Name) because it is not a .ps1 file"
                    continue
                } else {
                    Write-Debug "$($file.Name) is a source item"
                }
                #endregion File selection
                #-------------------------------------------------------------------------------

                #-------------------------------------------------------------------------------
                #region Object creation
                Write-Debug "  Creating item $($fileItem.BaseName) from $($fileItem.FullName)"
                try {
                    $ast = [Parser]::ParseFile($fileItem.FullName, [ref]$null, [ref]$null)
                }
                catch {
                    throw "Could not parse source item $($fileItem.FullName)`n$_"
                }

                $sourceObject = [PSCustomObject]@{
                    PSTypeName   = 'Stitch.SourceItemInfo'
                    Path         = $fileItem.FullName
                    Name         = $fileItem.BaseName
                    Ast          = $ast
                    Directory    = ''
                    Module       = ''
                    Type         = ''
                    Component    = ''
                    SubComponent = @()
                    Visibility   = ''
                    Verb         = ''
                    Noun         = ''
                }
                #endregion Object creation
                #-------------------------------------------------------------------------------

                #-------------------------------------------------------------------------------
                #region Path items
                Write-Debug "Getting relative path from root '$Root'"
                $adjustedPath = [System.IO.Path]::GetRelativePath($Root, $fileItem.FullName)
                Write-Debug "  - '$($fileItem.FullName)' adjusted path is '$adjustedPath'"
                [System.Collections.ArrayList]$pathItems = $adjustedPath -split [regex]::Escape([System.IO.Path]::DirectorySeparatorChar)
                Write-Debug "    - Items found in adjusted path:`n             '$($pathItems -join '; ')'"

                #endregion Path items
                #-------------------------------------------------------------------------------

                #-------------------------------------------------------------------------------
                #region Module name
                # Module should be the first folder in the list?
                $mod = $pathItems[0]
                Write-Debug "  - Checking for type in first item in the list: $mod"
                if ($sourceTypeMap.Keys -notcontains $mod) {
                    Write-Debug "  - Not found. Assuming module name is: $mod"
                    $sourceObject.Module = $mod
                    $pathItems.RemoveAt(0)
                    # if there is only one item left, then it is in the "module root" folder, which makes
                    # it a special file
                    if ($pathItems.Count -eq 1) {
                        $sourceObject.Type = 'resource'
                        $sourceObject.Visibility = 'private'
                    }
                } else {
                    Write-Verbose " $($fileItem.BaseName) with root $Root is missing module directory"
                }

                #endregion Module name
                #-------------------------------------------------------------------------------

                #-------------------------------------------------------------------------------
                #region File name
                <#------------------------------------------------------------------
                  Now the path items should be whatever is "inside" the module folder.

                  it may be:
                  - visibility, item (most common)
                  - visibility, component, item (preferred component style)
                  - component, visibility, item (less preferred)

                  ------------------------------------------------------------------#>

                #  so the first thing we can do is process the file part of the path
                Write-Debug '  - Testing filename for verb-noun'
                if ($fileItem.BaseName -match '(?<verb>\w+)-(?<noun>\w+)') {
                    Write-Debug "    - '$($Matches.verb)' and '$($Matches.noun)' found"
                    $sourceObject.Verb = $Matches.verb
                    $sourceObject.Noun = $Matches.noun
                } else {
                    Write-Debug "    - No match. Using $($fileItem.BaseName) as noun"
                    $sourceObject.Noun = $fileItem.BaseName
                }

                # reverse the order first, so we can walk "up" the directories
                $pathItems.Reverse()
                # and remove it
                $pathItems.RemoveAt(0)
                Write-Debug "Reversed and filename removed: '$($pathItems -join '; ')'"
                #endregion File name
                #-------------------------------------------------------------------------------


                <#------------------------------------------------------------------
                What is left are potentially visibility and/or component folders.

                If we find and remove the visibility, then the rest can be assumed
                to be component folders, if there are any
                ------------------------------------------------------------------#>

                #-------------------------------------------------------------------------------
                #region Visibility
                foreach ($pathItem in $pathItems) {
                    Write-Debug "  - Checking $pathItem"
                    if ($sourceTypeMap.Keys -contains $pathItem) {
                        $sourceObject.Visibility = $sourceTypeMap[$pathItem].Visibility
                        $sourceObject.Type = $sourceTypeMap[$pathItem].Type
                        $sourceObject.Directory = $pathItem
                        Write-Debug '    - Found mapping.'
                        Write-Debug "      Visibility => $($sourceObject.Visibility)"
                        Write-Debug "      Type       => $($sourceObject.Type)"
                        Write-Debug "      Directory  => $pathItem"
                        # We will cause an error if we try to remove an item
                        # while in a foreach, so store it for after
                        $visibility = $pathItem
                    } else {
                        $sourceObject.Directory = $pathItem
                        $sourceObject.Type = $pathItem
                        #! design decision: If the type is not identified in the map,
                        #! then the item is likely a resource, and it will not be in
                        #! an `Exported*` key in the manifest.  So the default
                        #! Visibility would be *private*
                        $sourceObject.Visibility = 'private'

                    }
                }
                $pathItems.Remove($visibility)

                #endregion Visibility
                #-------------------------------------------------------------------------------
                Write-Debug "after removing visibility, remaining is $($pathItems -join '; ')"

                #-------------------------------------------------------------------------------
                #region Component
                # the only thing left must be component/subcomponent folders?
                switch ($pathItems.Count) {
                    0 { continue }
                    1 {
                        Write-Debug "  One item left setting Component to $($pathItems[0])"
                        $sourceObject.Component = $pathItems[0]
                    }
                    default {
                        $c = $pathItems.Count
                        Write-Debug "  $c remaining path items"
                        $sourceObject.Component = $pathItems[$c - 1]
                        $sourceObject.SubComponent = ($pathItems[0..$c] -join '.')
                        Write-Debug "    Component => $($sourceObject.Component)"
                        Write-Debug "    SubComponent => $($sourceObject.SubComponent)"
                    }
                }
                #endregion Component
                #-------------------------------------------------------------------------------

                $sourceObject | Write-Output
            } catch {
                Write-Warning "$p is not a valid path`n$_"
            } # nested try
        } # end foreach
    } # end process block
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
