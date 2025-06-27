
param(
    [Parameter()]
    [string[]]$ExcludePathFromClean = (
        Get-BuildProperty ExcludePathFromClean @()
    )
)

<#
.SYNOPSIS
    Remove everything in the Artifact directory except 'modules' and 'backup'
#>
cleanup 'clean.artifacts' -Path $Artifact -Exclude $ExcludePathFromClean -Filter '*' -Recurse
