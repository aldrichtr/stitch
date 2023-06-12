<#
.SYNOPSIS
    Output the build parameters and their values
.DESCRIPTION
    This task will output all of the Parameters that are set in the build scripts, along with their values
    if set.
#>
task diag.build.parameters {
    $paramTable =[ordered]@{}
    Write-Build DarkBlue 'Build Parameters:'
    foreach ($key in (${*}.DP.Keys | Sort-Object)) {
        if ('BuildInfo' -eq $key) {
            $var = 'Run "Invoke-Build diag.build.configuration" for BuildInfo table'
        } else {
            $var = Get-Variable $key -ValueOnly
        }
        if ($null -eq $var) {
            $var = $false
        } elseif ($var.GetType() -like 'switch') {
            if (-not($var)) { $var = $false }
        } else {
        }
        $paramTable[$key] = $var
    }
    Write-Build DarkGray ($paramTable | ConvertTo-Yaml -KeepArray -Options DisableAliases)
}
