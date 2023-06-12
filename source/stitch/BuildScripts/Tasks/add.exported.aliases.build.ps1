<#
.SYNOPSIS
    Add the aliases to the manifest that should be exported from the module
.DESCRIPTION
    Foreach module in the source directory, this task will find any functions with aliases and add them to the
    'AliasesToExport' field in the manifest
#>

using namespace System.Management.Automation.Language

param(
    [Parameter()][string[]]$ExcludeAliasFromExport = (
        Get-BuildProperty ExcludeAliasFromExport @()
    )
)

<#
.SYNOPSIS
    Add the aliases to the manifest that should be exported from the module
#>
task add.exported.aliases {
     $BuildInfo | Foreach-Module {
        $config = $_
        $name = $config.Name
        $manifestFile = (Join-Path $config.Staging $config.ManifestFile)
        $allAliases = @()
        logDebug "Getting publicFunctions in"
        $functions = $config.SourceInfo | Where-Object {
            ($_.Type -like 'function') -and ($_.Visibility -like  'public')
        }
        foreach ($item in $functions) {
            logDebug "Looking for aliases in $($item.Name)"
            $aliasAttributes = $item.Ast.Find(
                {
                    param(
                        [Parameter()]
                        [Ast]$Ast
                    )
                    ($Ast -is [AttributeAst]) -and
                    ($Ast.Parent -is [ParamBlockAst]) -and
                    ($Ast.TypeName -like 'Alias')
                }, $true
            )
            if ($aliasAttributes.Count -gt 0) {
                :alias foreach ($aliasAttribute in $aliasAttributes) {
                    logInfo "found alias for $($item.Name)"
                    $aliasName = $aliasAttribute.PositionalArguments.Value
                    if ($ExcludeAliasFromExport -contains $aliasName) {
                        logInfo "Excluding $aliasName from Export because it is listed in ExcludeAliasFromExport"
                        continue alias
                    } else {
                        logDebug "Adding alias $aliasName for $($item.Name)"
                        $allAliases += $aliasName
                    }
                }
            }

        }
        if ($allAliases.Count -gt 0) {
            logDebug "Found $($allAliases.Count) aliases for $name"
            if (Test-Path $manifestFile) {
                Update-Metadata -Path $manifestFile -PropertyName 'AliasesToExport' -Value $allAliases
            } else {
                throw (logError "Could not add aliases to $manifestFile. File not found" -Passthru)
            }
        } else {
            logInfo "No aliases found in $name"
        }
    }
}
