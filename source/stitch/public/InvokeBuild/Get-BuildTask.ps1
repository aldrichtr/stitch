
function Get-BuildTask {
    [CmdletBinding()]
    param(
        # The name of the task to get
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ArgumentCompleter({ Invoke-TaskNameCompletion @args })]
        [string]$Name
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        function Add-TaskProperty {
            param(
                [ref]$TaskRef
            )
            #! if the task was written as 'phase <name>' then the InvocationName
            #! can be used to find it.  Add a property 'IsPhase' for easier sorting
            $TaskRef.Value | Add-Member -NotePropertyName Synopsis -NotePropertyValue (
                (Get-BuildSynopsis ${*}.All[$TaskRef.Value.Name] -ErrorAction SilentlyContinue) ?? ''
            )
            $TaskRef.Value | Add-Member -NotePropertyName IsPhase -NotePropertyValue (
                ( $TaskRef.Value.InvocationInfo.InvocationName -like 'phase' ) ? $true : $false
            )
            $TaskRef.Value | Add-Member -NotePropertyName Path -NotePropertyValue (
                Get-Item $TaskRef.Value.InvocationInfo.ScriptName
            )
            $TaskRef.Value | Add-Member -NotePropertyName Line -NotePropertyValue $TaskRef.Value.InvocationInfo.ScriptLineNumber
            $TaskRef.Value.PSObject.TypeNames.Insert(0, 'InvokeBuild.TaskInfo')
        }

    }
    process {
        if (Test-InInvokeBuild) {
            $taskData = ${*}.AllTasks
        } else {
            $taskData = Invoke-Build ??
        }
        if ($null -ne $taskData) {

            if ($PSBoundParameters.ContainsKey('Name')) {
                $task = $taskData[$Name]
                if (-not ([string]::IsNullorEmpty($task))) {
                    Add-TaskProperty ([ref]$task)
                    $task | Write-Output
                } else {
                    throw "There is no task named $Name in this project"
                }

            } else {
                foreach ($key in $taskData.Keys) {
                    $task = $taskData[$key]
                    Add-TaskProperty ([ref]$task)
                    $task | Write-Output
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
