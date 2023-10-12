
function Rename-SourceItem {
    <#
    .SYNOPSIS
        Rename the file and the function, enum or class in the file
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
        Position = 1,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # The New name of the function
        [Parameter(
        )]
        [string]$NewName,

        # Return the new file object
        [Parameter(
        )]
        [switch]$PassThru
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $predicates = @{
            function = {
                param($ast)
                $ast -is [System.Management.Automation.Language.FunctionDefinitionAst]
            }
            class = {
                param($ast)
                (($ast -is [System.Management.Automation.Language.TypeDefinitionAst]) -and
                ($ast.Type -like 'Class'))
            }
            enum = {
                param($ast)
                (($ast -is [System.Management.Automation.Language.TypeDefinitionAst]) -and
                ($ast.Type -like 'Enum'))
            }
        }

    }
    process {
        :file foreach ($file in $Path) {
            if (Test-Path $file) {
                $fileItem = Get-Item $file
                try {
                    $ast = [Parser]::ParseFile($fileItem.FullName, [ref]$null, [ref]$null)
                }
                catch {
                    throw "Could not parse source item $($fileItem.FullName)`n$_"
                }
                # try to find the type of SourceInfo this is
                $typeWasFound = $false
                :type foreach ($type in $predicates.GetEnumerator()) {
                    $innerAst = $ast.Find($type.Value, $false)
                    if ($null -ne $innerAst) {
                        $typeWasFound = $true
                        $oldName = $innerAst.Name
                        Write-Verbose "Found $($type.Name)"
                        break type
                    }
                }
                #! replace all occurances of the old name in the file
                $newExtent = $ast.Extent.Text -replace [regex]::Escape($oldName), $NewName
                try {
                    $newExtent | Set-Content -Path $fileItem.FullName
                    Write-Debug "Updating content in $($fileItem.Name)"
                }
                catch {
                    throw "Could not write content to $($fileItem.FullName)`n$_"
                }

                $baseDirectory = $fileItem | Split-Path -Parent
                $originalExtension = $fileItem.Extension # pretty sure this will always be .ps1, but ...
                $NewPath = (Join-Path $baseDirectory "$NewName$originalExtension")
                try {
                    Move-Item $fileItem.FullName -Destination $NewPath
                    Write-Debug "Renaming file to $NewPath"
                }
                catch {
                    throw "Could not rename $($fileItem.Name)"
                }
                if ($PassThru) {
                    Get-Item $NewPath
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
