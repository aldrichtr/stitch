
function Resolve-ProjectName {
    [CmdletBinding()]
    param(
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $config = Get-BuildConfiguration
        if ([string]::IsNullorEmpty($config.Project.Name)) {
            Write-Debug "Project name not set in configuration`n trying to resolve project root"
            $root = (Resolve-ProjectRoot).BaseName
        } else {
            Write-Debug "Project Name found in configuration"
            $root = $config.Project.Name
        }
    }
    end {
        $root
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
