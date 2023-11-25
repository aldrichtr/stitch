<#
.SYNOPSIS
    This function is called at the start of a task **scriptblock**
.NOTES
    The $Job variable is the ScriptBlock object
#>

Enter-BuildJob {
    param($Path)
    Invoke-OutputHook 'EnterBuildJob' 'Before'

    foreach ($attribute in $Job.Attributes) {
        $attribute.OnEnter()
    }
    Invoke-BuildNotification -Status Passed -Text "Starting $($Task.Name)"
    Invoke-OutputHook 'EnterBuildJob' 'After'
}
