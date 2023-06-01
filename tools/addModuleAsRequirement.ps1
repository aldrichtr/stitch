param(
    # The names of the modules to add to the requirements
    [Parameter(
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
    )]
    [string[]]$Name,

    # path to requirements data file
    [Parameter(
    )]
    [string]$Requirements = 'requirements.psd1',

    # Do not write to the file, (to the console instead)
    [Parameter(
    )]
    [switch]$NoWrite
)
begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
}
process {
    Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
}
end {
    $allInstalled = Get-InstalledModule -Name $Name
    if ($allInstalled.Count -gt 0) {

        Write-Verbose "  - Found $($allInstalled.Count) modules to add"
        $ordered = [ordered]@{}

        $requirementData = Import-Psd $Requirements
        foreach($installed in $allInstalled) {
            Write-Verbose "Getting requirements from $Requirements"

            if ($requirementData.Keys -contains $moduleName) {
                if ($requirementData[$moduleName].Version -eq $installed.Version) {
                    Write-Verbose "$moduleName v$($installed.Version) already exists as a requirement"
                } else {
                    Write-Verbose "Updating version from $($requirementData[$moduleName].Version) to $($installed.Version)"
                    $requirementData[$moduleName].Version = $installed.Version
                }
            } else {
                Write-Verbose "Adding $($installed.Name) to requirements"
                $installed | Select-Object Name, Version | ForEach-Object {
                    $requirementData[$_.Name] = @{ Version = $_.Version; Tags = @('ci') }
                }
            }
        }

        $ordered.Add('PSDependOptions', $requirementData.PSDependOptions)
        $requirementData.Remove('PSDependOptions')

        $requirementData.Keys | Sort-Object | ForEach-Object {
            $ordered.Add($_, $requirementData[$_])
        }

        if (-not($NoWrite)) {
            $ordered | ConvertTo-Psd | Set-Content $Requirements
        } else {
            $ordered
        }

    }
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
}
