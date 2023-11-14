
function Update-ManifestField {
    [CmdletBinding()]
    param(
        # Specifies a path to a manifest file
        [Parameter(
        Position = 2,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # Field in the Manifest to update
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [string]$PropertyName,

        # List of strings to add to the field
        [Parameter(
            Mandatory,
            Position = 1
        )]
        [string[]]$Value
    )

    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        try {
            Write-Debug "Loading manifest $Path"
            $manifestItem = Get-Item $Path
            $manifestObject = Import-Psd $manifestItem.FullName
        }
        catch {
            throw "Cannot load $($Path)`n$_"
        }

        $options = $PSBoundParameters
        $null = $options.Remove('Name')

        if ($manifestObject.ContainsKey($PropertyName)) {
            #-------------------------------------------------------------------------------
            #region Field exists
            Write-Debug "  - Manifest has a $PropertyName field.  Updating"
            try {
                Update-Metadata @options
            }
            catch {
                throw "Cannot update $PropertyName in $Path`n$_"
            }
            #endregion Field exists
            #-------------------------------------------------------------------------------
        } else {
            #-------------------------------------------------------------------------------
            #region Commented
            Write-Debug "Manifest does not have $PropertyName field.  Looking for it in comments"
            $fieldToken = $manifestItem | Find-ParseToken $PropertyName Comment
            if ($null -ne $fieldToken) {
                Write-Debug "  - Found comment"
                try {
                    $manifestItem | ConvertFrom-CommentedProperty -Property $PropertyName
                    Update-Metadata @options
                }
                catch {
                    throw "Cannot update $PropertyName in $Path`n$_"
                }

                #endregion Commented
                #-------------------------------------------------------------------------------
            } else {
                #-------------------------------------------------------------------------------
                #region Field missing
                #! Update-ModuleManifest is not really the best option for editing the psd1, because
                #! it does a poor job of formatting "proper" arrays, and it doesn't deal with "non-standard"
                #! fields very well.  However, if the field is missing from the file, it is better to use
                #! Update-ModuleManifest than to clobber the comments and formatting ...

                Write-Debug "Could not find $PropertyName in Manifest.  Calling Update-ModuleManifest"
                $null = $options.Clear()
                $options = @{
                    Path = $Path
                    $PropertyName = $Value
                }
                try {
                    Update-ModuleManifest @options
                } catch {
                    throw "Cannot update $PropertyName in $Path`n$_"
                }
            #endregion Field missing
            #-------------------------------------------------------------------------------

            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
