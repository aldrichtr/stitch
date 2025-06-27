function Find-InvokeBuildScript {
    <#
    .SYNOPSIS
        Find all "build script" files.  These are files that contain tasks to be executed by Invoke-Build
    .LINK
        Find-InvokeBuildTaskFile
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations to look for build scripts.
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $buildScriptPattern = "*.build.ps1"
    }
    process {
        foreach ($location in $Path) {
            if (Test-Path $location) {
                $options = @{
                    Path = $location
                    Recurse = $true
                    Filter = $buildScriptPattern
                }
                Get-ChildItem @options
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
