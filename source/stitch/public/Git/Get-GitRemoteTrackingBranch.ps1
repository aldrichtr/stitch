function Get-GitRemoteTrackingBranch {
    Get-GitBranch | Select-Object -ExpandProperty TrackedBranch
}
