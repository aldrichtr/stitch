function Get-ProjectPath {
    <#
    .SYNOPSIS
        Retrieve the paths to the major project components. (Source, Tests, Docs, Artifacts, Staging)
    #>
    [CmdletBinding()]
    param(
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)'"
        $stitchPathFiles = @(
            '.stitch.config.psd1',
            '.stitch.psd1',
            'stitch.config.psd1'
            )
    }
    process {
        $root = Resolve-ProjectRoot
        if ($null -ne $root) {
            $possibleBuildRoot = $PSCmdlet.GetVariableValue('BuildRoot')
            if (-not ([string]::IsNullorEmpty($possibleBuildRoot))) {
                $root = $possibleBuildRoot
            } else {
                $root = Get-Location
            }
        }
        Write-Verbose "Looking for path config file in $root"
        $pathConfigFiles = (Get-ChildItem -Path "$root/*.psd1" -Include $stitchPathFiles)
        if ($pathConfigFiles.Count -gt 0) {
            Write-Debug ('Found ' + ($pathConfigFiles.Name -join "`n"))
            $pathConfigFile = $pathConfigFiles[0]
        }

        if ($null -ne $pathConfigFile) {
            Write-Verbose "  - found $pathConfigFile"
            try {
                $config = Import-Psd $pathConfigFile
                $resolved = @{}
                foreach ($key in $config.Keys) {
                    $resolved[$key] = (Resolve-Path $config[$key])
                }
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
            [PSCustomObject]$resolved | Write-Output
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
