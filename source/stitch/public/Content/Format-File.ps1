
function Format-File {
    <#
    .SYNOPSIS
        Run PSSA formatter on the given files
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # Path to the code format settings
        [Parameter(
            Position = 0
        )]
        [object]$Settings = 'CodeFormatting.psd1'
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            if ($null -ne $psEditor) {
                $currentFile = $psEditor.GetEditorContext().CurrentFile.Path
                if (Test-Path $currentFile) {
                    Write-Debug "Formatting current VSCode file '$currentFile'"
                    $Path += $currentFile
                }
            }
        }
        foreach ($file in $Path) {
            if (Test-Path $file) {
                $content = Get-Content $file -Raw
                $options = @{
                    ScriptDefinition = $content
                    Settings         = $Settings
                }
                try {
                    Invoke-Formatter @options | Set-Content $file
                } catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
