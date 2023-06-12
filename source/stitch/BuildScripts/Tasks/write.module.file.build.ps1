
param(
    [Parameter()][string[]]$ModuleFileIncludeTypes = (
        Get-BuildProperty ModuleFileIncludeTypes @('enum', 'class', 'function')
    )
)
#synopsis: Create module file (.psm1) for each module folder in Source.
task write.module.file {
     $BuildInfo | Foreach-Module {
        $config = $_
        $name = $config.Name
        logInfo "Generating module file (.psm1) for $name"

        $moduleFile = (Join-Path $config.Staging $config.ModuleFile)
        logDebug "Module file is $moduleFile"
        if (-not(Test-Path $moduleFile)) {
            try {
            $null = New-Item $moduleFile -ItemType File
            logInfo "Created new module file"
            }
            catch {
                throw "Could not create $moduleFile.`n$_"
            }
        }
        #! We want to handle functions differently so:
        #  1. Create an array list to store the updated list
        #  2. If function is part of the list, remove it and
        #  3. Handle them after the other types are processed
        $includeTypes = [System.Collections.ArrayList]($ModuleFileIncludeTypes)

        logDebug "Types to be merged: $($includeTypes -join ', ')"
        if ($includeTypes -contains 'function') {
            logDebug 'Separating functions from other types'
            $null = $includeTypes.Remove('function')
            $processFunctions = $true
        }
        foreach ($type in $includeTypes) {
            logInfo "Processing source items in $type"
            $items = $config.SourceInfo | Where-Object -Property Type -Like $type
            if ($items.Count -gt 0) {
                logDebug "merging $(@($items | Select-Object -Expand Name) -join ', ') as $type section"
                $items | Merge-SourceItem $moduleFile -AsSection $type
            } else {
                logDebug "No $type source items found"
            }
        }

        if ($processFunctions) {
            logInfo "Processing source items in 'private'"
            $private = $config.SourceInfo | Where-Object {
                ($_.Type -like 'function') -and ($_.Visibility -like 'private')
            }
            logInfo "Processing source items in 'public'"
            $public = $config.SourceInfo | Where-Object {
                ($_.Type -like 'function') -and ($_.Visibility -like 'public')
            }

            logDebug "merging $(@($private | Select-Object -Expand Name) -join ', ') as 'private' section"
            $private | Merge-SourceItem $moduleFile -AsSection 'Private functions'
            logDebug "merging $(@($public | Select-Object -Expand Name) -join ', ') as 'public' section"
            $public | Merge-SourceItem $moduleFile -AsSection 'Public functions'
        }
    }
}
