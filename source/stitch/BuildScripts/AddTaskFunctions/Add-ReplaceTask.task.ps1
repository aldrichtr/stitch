<#
.SYNOPSIS
    Add a replace keyword that replaces the given token in the file with a new string
.EXAMPLE
    replace update.readme.version '^Version: \d+\.\d+\.\d+ "Version: $($BuildInfo.Version.MajorMinorPatch)" 'README.md'
#>

Set-Alias replace Add-ReplaceTask
function Add-ReplaceTask {
    [CmdletBinding()]
    param(
        # Name of the task
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [string]$Name,

        # The token to replace, written as a regular-expression
        [Parameter(
            Position = 1,
            Mandatory
        )]
        [string]$Token,

        # The value to replace the token with
        [Parameter(
            Position = 2,
            Mandatory
        )]
        [Alias('Value')]
        [string]$With,

        # File(s) to replace tokens in
        [Parameter(
            Mandatory,
            Position = 3
        )]
        [string]$In
    )

    Add-BuildTask -Name $Name -Data $PSBoundParameters -Source $MyInvocation {
        if (Test-Path $Task.Data.In) {
            $options = $Task.Data
            $null = $options.Remove('Name')
            logInfo "Replacing $($options.Token) with $($options.With) in $($options.In)"
            $options.In | Invoke-ReplaceToken @options | Set-Content $options.In
        }
    }
}
