
param(
    [Parameter()]
    [string[]]$ExcludePathFromClean = (
        Get-BuildProperty ExcludePathFromClean @()
    )
)
<#
.SYNOPSIS
    Remove everything in the Staging directory
#>
cleanup clean.staging "$Staging/*" -Recurse
