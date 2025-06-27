
function Checkpoint-GitWorkingDirectory {
    <#
    .SYNOPSIS
        Save all changes (including untracked) and push to upstream
    #>
    [CmdletBinding()]
    param(
        # Message to use for the checkpoint commit.
        # Defaults to:
        # `[checkpoint] Creating checkpoint before continuing <date>`
        [Parameter(
        )]
        [string]$Message
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('Message'))) {
            $Message = "[checkpoint] Creating checkpoint before continuing $(Get-Date -Format FileDateTimeUniversal)"
        }

        Write-Verbose 'Staging all changes'
        Add-GitItem -All
        Write-Verbose 'Commiting changes'
        Save-GitCommit -Message $Message
        Write-Verbose 'Pushing changes upstream'
        if (-not(Get-GitBranch -Current | Select-Object -ExpandProperty IsTracking)) {
            Get-GitBranch -Current | Send-GitBranch -SetUpstream
        } else {
            Get-GitBranch -Current | Send-GitBranch
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
