function Test-InInvokeBuild {
    [CmdletBinding()]
    param(
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $invokeBuildPattern = 'Invoke-Build.ps1'
    }
    process {
        $callStack = Get-PSCallStack
        $inInvokeBuild = $false
        for ($i = 1; $i -lt $callStack.Length; $i++) {
            $caller = $callStack[$i]
            Write-Debug "This caller is $($caller.Command)"
            if ($caller.Command -match $invokeBuildPattern) {
                $inInvokeBuild = $true
                break
            }
        }
        $inInvokeBuild
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
