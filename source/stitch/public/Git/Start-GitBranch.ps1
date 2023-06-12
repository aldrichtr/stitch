
function Start-GitBranch {
    param(
        [string]$Name
    )
    New-GitBranch $Name | Set-GitHead
}
