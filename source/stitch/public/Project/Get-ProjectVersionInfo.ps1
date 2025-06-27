
function Get-ProjectVersionInfo {
    <#
    .SYNOPSIS
        Return a collection of Version Information about the project
    .DESCRIPTION
        gitversion dotnet tool
        git describe
        version.(psd1|json|yaml)
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'gitdescribe'
    )]
    param(
        # Use git describe instead of gitversion
        [Parameter(
            ParameterSetName = 'gitdescribe'
        )]
        [switch]$UseGitDescribe,

        # Use the information in version.(psd1|json|yml)
        [Parameter(
            ParameterSetName = 'versionfile'
        )]
        [switch]$UseVersionFile
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug 'Checking for version information'
        try {
            if ($UseVersionFile) {
                Get-VersionFileInfo
            } else {
                $cmd = Get-Command 'gitversion' -ErrorAction SilentlyContinue

                if (($null -ne $cmd) -and (-not ($UseGitDescribe))) {
                    Get-GitVersionInfo
                } else {
                    Get-GitDescribeInfo
                }
            }
        } catch {
            $message       = "Could not get version information for the project"
            $exceptionText = ( @($message, $_.ToString()) -join "`n")
            $thisException = [Exception]::new($exceptionText)
            $eRecord       = New-Object System.Management.Automation.ErrorRecord -ArgumentList (
                $thisException,
                $null,  # errorId
                $_.CategoryInfo.Category, # errorCategory
                $null  # targetObject
            )
            $PSCmdlet.ThrowTerminatingError( $eRecord )
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
