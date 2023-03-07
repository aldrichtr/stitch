
<#
.SYNOPSIS
    Format the header of the build output
.NOTES
    Called at the start of each task
#>

Set-BuildHeader {
    #-------------------------------------------------------------------------------
    #region Before hook

    if ($null -ne $Output) {
        if ($Output.ContainsKey('SetBuildHeader')) {
            if ($Output.SetBuildHeader.ContainsKey('Before')) {
                if ($Output.SetBuildHeader.Before -is [scriptblock]) {
                    $Output.SetBuildHeader.Before.invoke()
                } elseif ($Output.SetBuildHeader.Before -is [string]) {
                    logEnter $Output.SetBuildHeader.Before
                }
            }
        }
    }

    #endregion Before hook
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region Stitch code

    if ($task.InvocationInfo.InvocationName -like 'phase') {
        logEnter "$('-' * 80)"
        logEnter "Phase: $($Task.Name.ToUpper() -replace '\.', ' ')" (Get-BuildSynopsis $Task)
        $jbs = $Task.Jobs | ForEach-Object {
            $j = $_
            if ($j -is [scriptblock]) {
                Write-Output '{}'
            } elseif ($j -is [string]) {
                Write-Output $j
            }
        }
        logEnter "Tasks : $($jbs -join ', ')"
    } else {
        logEnter "- Task: $($Task.Name.ToUpper() -replace '\.', ' ')" (Get-BuildSynopsis $Task)

    }

    #endregion Stitch code
    #-------------------------------------------------------------------------------

    #-------------------------------------------------------------------------------
    #region After hook
    if ($null -ne $Output) {
        if ($Output.ContainsKey('SetBuildHeader')) {
            if ($Output.SetBuildHeader.ContainsKey('After')) {
                if ($Output.SetBuildHeader.After -is [scriptblock]) {
                    $Output.SetBuildHeader.After.invoke()
                } elseif ($Output.SetBuildHeader.After -is [string]) {
                    logEnter $Output.SetBuildHeader.After
                }
            }
        }
    }

    #endregion After hook
    #-------------------------------------------------------------------------------
}
