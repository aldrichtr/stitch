
using namespace System.Diagnostics.CodeAnalysis
<#
.SYNOPSIS
    Update the PSModulePath environment variable with paths from the requirements.psd1
.DESCRIPTION
    `set.psmodulepath` task loads the requirements.psd1 files looking for module paths specified in the `Target`
    property. If any are found and they do not exist in the $env:PSModulePath variable, they are added
#>
[SuppressMessageAttribute(
    'PSReviewUnusedParameter','',
    Justification = 'Parameters used inside task scope'
)]
param(
    [Parameter()]
    [switch]$SkipDependencyCheck = (
        Get-BuildProperty SkipDependencyCheck $false
    ),

    [Parameter()][string[]]$DependencyTags = (
        Get-BuildProperty DependencyTags @()
    )
)


#synopsis: Update the PSModulePath environment variable
task set.psmodulepath {
    if (-not($SkipDependencyCheck)) {
        $targets = [System.Collections.ArrayList]@()
        logInfo "Checking dependencies with tags $($DependencyTags -join ', ')"
        $targets = Get-Dependency -Tags:$DependencyTags -Recurse:$true
        | Select-Object -ExpandProperty Target -Unique
        | Where-Object {
                ($_ -notlike 'CurrentUser') -or
                ($_ -notlike 'AllUsers') }
        | ForEach-Object { Resolve-Path $_ }

        if ($targets.Count -gt 0) {
            $originalModulePaths = [System.Collections.ArrayList]@(
            ([Environment]::GetEnvironmentVariable('PSModulePath') -split ';')
            )

            $options = @{
                ReferenceObject  = $originalModulePaths
                DifferenceObject = $targets
            }

            #! get paths that are not in the current PSModulePath already
            $notInModulePath = Compare-Object @options
            | Where-Object SideIndicator -Like '=>'


            if ($notInModulePath.count -gt 0) {
                foreach ($modulePath in $notInModulePath) {
                    if (Test-Path $target) {
                        logDebug "Looking for $target in PSModulePath"
                        if ($modulePaths -contains $targetPath) {
                            logInfo "$target already set"
                        } else {
                            logInfo "Prepending $target on PSModulePath"
                            $modulePaths = $target , $modulePaths
                        }
                    } else {
                        logWarn "Skipping $targetPath because it does not exist"
                    }
                }
            } else {
                logInfo 'No targets specified in requirements with given tags'
            }
            #! did the count increase since we started?
            if ($modulePaths.Count -gt $pathCount) {
                logInfo 'Updating PSModulePath environment variable'
                [Environment]::SetEnvironmentVariable('PSModulePath', ($new_mod_paths -join ';'))
            } else {
                logInfo 'No paths need to be added'
            }
        } else {
            logInfo 'No paths found in dependency targets'
        }
    } else {
        logInfo 'Module dependency check skipped (-SkipDependencyCheck was set)'
    }
}
