
param(
    [Parameter()]
    [string[]]$ExcludePathFromClean = (
        property ExcludePathFromClean @()
    )
)
<#
.SYNOPSIS
    Remove everything in the Staging directory
#>
cleanup clean.staging "$Staging/*" -Recurse
