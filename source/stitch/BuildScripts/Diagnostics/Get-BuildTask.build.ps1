
function Get-BuildTask {
    [CmdletBinding()]
    param()
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        foreach ($task in ${*}.All.get_Values()) {
            #! if the task was written as 'phase <name>' then the InvocationName
            #! can be used to find it.  Add a property 'IsPhase' for easier sorting
            $task | Add-Member -NotePropertyName IsPhase -NotePropertyValue (
            ( $task.InvocationInfo.InvocationName -like 'phase' ) ? $true : $false
            )
            $task | Write-Output
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
