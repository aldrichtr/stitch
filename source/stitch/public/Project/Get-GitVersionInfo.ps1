
function Get-GitVersionInfo {
    <#
    .SYNOPSIS
        Return the output of gitversion dotnet tool as an object
    #>
    [CmdletBinding()]
    param(
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug '  - Checking for gitversion utility'
        $gitverCmd = Get-Command dotnet-gitversion.exe -ErrorAction SilentlyContinue
        if ($null -ne $gitverCmd) {
            Write-Verbose 'Using gitversion for version info'
            $gitVersionCommandInfo = & $gitverCmd @('-?')

            Write-Debug '  - gitversion found.  Getting version info'
            $gitVersionCommandInfo | Write-Debug
            $gitVersionOutput = & $gitverCmd @( '-output', 'json')
            if ([string]::IsNullorEmpty($gitVersionOutput)) {
                Write-Warning 'No output from gitversion'
            } else {
                Write-Debug "Version info: $gitVersionOutput"
                try {
                    $gitVersionOutput | ConvertFrom-Json | Write-Output
                } catch {
                    throw "Could not parse json:`n$gitVersionOutput`n$_"
                }
            }

        }
        Write-Debug '    - gitversion not found'
        Write-Information "GitVersion is not installed.`nsee <https://gitversion.net/docs/usage/cli/installation> for details"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
