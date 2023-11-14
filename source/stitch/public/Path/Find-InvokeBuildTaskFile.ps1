
function Find-InvokeBuildTaskFile {
    <#
    .SYNOPSIS
        Find all "task type" files.  These are files that contain "extensions" to the task types.  They define a
        function that creates tasks.
    .LINK
        Find-InvokeBuildScript
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations to look for task files.
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
        $taskFilePattern = "*.task.ps1"
    }
    process {
        foreach ($location in $Path) {
            if (Test-Path $location) {
                $options = @{
                    Path = $location
                    Recurse = $true
                    Filter = $taskFilePattern
                }
                Get-ChildItem @options
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
