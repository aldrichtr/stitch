using namespace System.Management.Automation.Language
function Merge-SourceItem {
    [CmdletBinding()]
    param(
        # The SourceItems to be merged
        [Parameter(
            ValueFromPipeline
        )]
        [PSTypeName('Stitch.SourceItemInfo')][object[]]$SourceItem,

        # File to merge the SourceItem into
        [Parameter(
            Position = 0
        )]
        [string]$Path,

        # Optionally wrap the given source items in `#section/endsection` tags
        [Parameter(
        )]
        [string]$AsSection
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $pre = '#region {0} {1}'
        $post = '#endregion {0} {1}'
        $root = Resolve-ProjectRoot

        $sb = New-Object System.Text.StringBuilder

        if ($PSBoundParameters.ContainsKey('AsSection')) {
            $null = $sb.AppendJoin('', @('#', ('=' * 79))).AppendLine()
            $null = $sb.AppendFormat( '#region {0}', $AsSection).AppendLine()
        }

        #-------------------------------------------------------------------------------
        #region Setup
        $sourceInfoUsingStatements = [System.Collections.ArrayList]@()

        $sourceInfoRequires = [System.Collections.ArrayList]@()
        #endregion Setup
        #-------------------------------------------------------------------------------


    }
    process {
        Write-Debug "Processing SourceItem $($PSItem.Name)"

        #-------------------------------------------------------------------------------
        #region Parse SourceItem
        #-------------------------------------------------------------------------------
        #region Content
        Write-Debug "Parsing SourceItem $($PSItem.Name)"
        #! The first NamedBlock in the AST *should* be the enum, class or function
        $predicate = { param($a) $a -is [NamedBlockAst] }
        $ast = $PSItem.Ast
        if ($null -eq $ast) { throw "Could not parse $($PSItem.Name)" }
        $nb = $ast.Find($predicate, $false)

        $start = $nb.Extent.StartLineNumber
        $end = $nb.Extent.EndLineNumber
        Write-Debug " - First NamedBlock found starting on line $start ending on line $end"

        $relativePath = $PSItem.Path -replace [regex]::Escape($root) , ''
        #! remove the leading '\' if it's there
        if ($relativePath.SubString(0,1) -like '\') {
            $relativePath = $relativePath.Substring(1,($relativePath.Length - 1))
        }

        Write-Debug " - Setting relative path to $relativePath"
        #endregion Content
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Using statements
        if ($ast.UsingStatements.Count -gt 0) {
            Write-Debug ' - Storing using statements'
            $sourceInfoUsingStatements += $ast.UsingStatements
        }

        #endregion Using statements
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Requires statements

        if ($ast.ScriptRequirements.Count -gt 0) {
            Write-Debug ' - Storing Requires statements'
            $sourceInfoRequires += $ast.ScriptRequirements
        }
        #endregion Requires statements
        #-------------------------------------------------------------------------------

        #endregion Parse SourceItem
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region SourceItem content
        Write-Debug " - Merging $($PSItem.Name) contents"
        $null = $sb.AppendFormat( $pre, $relativePath, $start ).AppendLine()
        $null = $sb.Append( $nb.Extent.Text).AppendLine()
        $null = $sb.AppendFormat( $post, $relativePath, $end).AppendLine()

        #endregion SourceItem content
        #-------------------------------------------------------------------------------
    }
    end {
        #-------------------------------------------------------------------------------
        #region Update module content

        #-------------------------------------------------------------------------------
        #region Add sourceItem
        if ($PSBoundParameters.ContainsKey('AsSection')) {
            $null = $sb.AppendFormat( '#endregion {0}', $AsSection).AppendLine()
            $null = $sb.AppendJoin('', @('#', ('=' * 79))).AppendLine()
        }

        Write-Debug "Writing new content to $Path"
        $sb.ToString() | Add-Content $Path
        $null = $sb.Clear()
        #endregion Add sourceItem
        #-------------------------------------------------------------------------------
        #-------------------------------------------------------------------------------
        #region Parse module
        Write-Debug "$Path exists.  Parsing contents"
        $moduleText = Get-Content $Path
        $module = [Parser]::ParseInput($moduleText, [ref]$null, [ref]$null)
        $content = $moduleText
        #endregion Parse module
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Requires statements
        Write-Debug ' - Parsing Requires statements'
        $combinedRequires = $module.ScriptRequirements + $sourceInfoRequires

        if (-not([string]::IsNullorEmpty($combinedRequires.ScriptRequirements.RequiredApplicationId))) {
            $s = "#Requires -ShellId $($combinedRequires.ScriptRequirements.RequiredApplicationId)"
            $content = ($content) -replace [regex]::Escape($s), ''
            $null = $sb.AppendLine($s)
            Remove-Variable s
        }
        if (-not([string]::IsNullorEmpty($combinedRequires.ScriptRequirements.RequiredPSVersion))) {
            $s = "#Requires -Version $($combinedRequires.ScriptRequirements.RequiredPSVersion)"
            $content = ($content) -replace [regex]::Escape($s), ''
            $null = $sb.AppendLine($s)
            Remove-Variable s
        }
        foreach ($rm in $combinedRequires.ScriptRequirements.RequiredModules) {
            $s = "#Requires -Modules $($rm.ToString())"
            $content = ($content) -replace [regex]::Escape($s), ''
            $null = $sb.AppendLine($s)
            Remove-Variable s
        }
        foreach ($ra in $combinedRequires.ScriptRequirements.RequiredAssemblies) {
            $s = "#Requires -Assembly $ra"
            $content = ($content) -replace [regex]::Escape($s), ''
            $null = $sb.AppendLine($s)
            Remove-Variable s
        }
        foreach ($re in $combinedRequires.ScriptRequirements.RequiredPSEditions) {
            $s = "#Requires -PSEdition $re"
            $content = ($content) -replace [regex]::Escape($s), ''
            $null = $sb.AppendLine($s)
            Remove-Variable s
        }
        foreach ($rp in $combinedRequires.ScriptRequirements.RequiresPSSnapIns) {
            $s = "#Requires -PSnapIn $($rp.Name)"
            if (-not([string]::IsNullorEmpty($rp.Version))) {
                $s += " -Version $(rp.Version)"
            }
            $content = ($content) -replace [regex]::Escape($s), ''
            $null = $sb.AppendLine($s)
            Remove-Variable s
        }

        if ($combinedRequires.ScriptRequirements.IsElevationRequired) {
            $s = '#Requires -RunAsAdministrator'
            $content = ($content) -replace [regex]::Escape($s), ''
            $null = $sb.AppendLine($s)
            Remove-Variable s
        }
        #endregion Requires statements
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Using statements
        $combinedUsingStatements = $module.UsingStatements + $sourceInfoUsingStatements

        if ($combinedUsingStatements.Count -gt 0) {
            Write-Debug " - Parsing using statements in $Path"
            Write-Debug "There are $($combinedUsingStatements.Count) using statements"
            Write-Debug "$($combinedUsingStatements | Select-Object Name, UsingStatementKind | Out-String)"
            foreach ($kind in [UsingStatementKind].GetEnumValues()) {
                Write-Debug "   - Checking for using $kind statements"
                $statements = $combinedUsingStatements | Where-Object UsingStatementKind -Like $kind

                if ($statements.Count -gt 0) {
                    Write-Debug "     - $($statements.Count) found"
                    $added = @()
                    foreach ($statement in $statements) {
                        $s = $statement.Extent.Text
                        if ($added -contains $s) {
                            Write-Debug "       - '$s' already processed"
                        } else {
                            Write-Debug "       - Looking for '$s' in content"
                            # first, remove the line from the original content
                            if (($content) -match [regex]::Escape($s)) {
                                Write-Debug "       - found '$s' in content"
                                $content = ($content) -replace [regex]::Escape($s), ''
                            }
                            $null = $sb.AppendLine($s)
                            $added += $s
                        }
                    }
                }
            }
        } else {
            Write-Debug 'No using statements in module or sourceInfo'
        }
        #endregion Using statements
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Content
        Write-Debug "Writing content back to $Path"
        $null = $sb.AppendJoin("`n", $content)
        $sb.ToString() | Set-Content $Path
        #endregion Content
        #-------------------------------------------------------------------------------

        #endregion Update module content
        #-------------------------------------------------------------------------------

    }
}
