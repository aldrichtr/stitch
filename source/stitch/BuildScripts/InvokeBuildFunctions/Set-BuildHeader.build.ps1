
<#
.SYNOPSIS
    Format the header of the build output
.DESCRIPTION
    Add content before and/or after using the `Output.SetBuildHeader.Before` and `Output.SetBuildHeader.After` keys.
    This can either be a scriptblock or a string
.NOTES
    Called at the start of each task
#>

Set-BuildHeader {
    param($Path)
    Invoke-OutputHook 'SetBuildHeader' 'Before'
    $pathParts = [System.Collections.ArrayList]@($Path -split '/')
    $pathCount = $pathParts.Count

    $currentTask = $pathParts[$pathCount - 1].ToUpper() -replace '\.', ' '
    $null = $pathParts.RemoveAt($pathCount - 1)
    $headerOutput = "$currentTask : " + ($pathParts -join ' > ').ToUpper()
    logEnter "- $headerOutput"

    Invoke-OutputHook 'SetBuildHeader' 'After'
}
