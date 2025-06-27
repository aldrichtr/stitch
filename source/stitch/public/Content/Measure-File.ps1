
function Measure-File {
    <#
    .SYNOPSIS
        Run PSSA analyzer on the given files
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # Path to the code format settings
        [Parameter(
        )]
        [object]$Settings = 'PSScriptAnalyzerSettings.psd1',

        # Optionally apply fixes
        [Parameter(
        )]
        [switch]$Fix
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            if ($null -ne $psEditor) {
                $currentFile = $psEditor.GetEditorContext().CurrentFile.Path
                if (Test-Path $currentFile) {
                    Write-Debug "Formatting current VSCode file"
                    $Path += $currentFile
                }
            }
        }
        foreach ($file in $Path) {
            if (Test-Path $file) {
                $options = @{
                    Path     = $file
                    Settings = $Settings
                    Fix      = $Fix
                }
                try {
                    Invoke-ScriptAnalyzer @options
                } catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
