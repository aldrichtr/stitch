
param(
    [Parameter()]
    [string[]]$ExcludePathFromClean = (
        property ExcludePathFromClean @()
    )
)

<#
.SYNOPSIS
    Remove everything in the Artifact directory except 'modules' and 'backup'
#>
cleanup 'clean.artifacts' -Path $Artifact -Exclude $ExcludePathFromClean -Filter '*' -Recurse
