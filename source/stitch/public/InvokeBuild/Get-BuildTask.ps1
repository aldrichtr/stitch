
function Get-BuildTask {
    [CmdletBinding()]
    param(
        # The name of the task to get
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ArgumentCompleter({ Invoke-TaskNameCompletion @args })]
        [string]$Name
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (Test-InInvokeBuild) {
            Write-Debug 'Running under Invoke-Build'
            $allData = $PSCmdlet.GetVariableValue('*')
            if ($null -ne $allData) {
                Write-Debug 'Found the star variable'
                Write-Debug "$($allData.All | Show-ObjectProperties | Out-String)"
                $taskData = $allData.All
            } else {
                throw 'Could not retrieve task from Invoke-Build'
            }
        } else {
            $taskData = Invoke-Build ??
        }

        if ($null -ne $taskData) {
            $descriptions = Invoke-Build ?
            foreach ($key in $taskData.Keys) {
                $task = $taskData[$key]
                if ($null -ne $task) {
                    if ($null -eq $task.Synopsis) {
                        $synopsis = (
                            $descriptions
                            | Where-Object -Property Name -Like $key
                            | Select-Object -ExpandProperty Synopsis
                        ) ?? 'No Synopsis'
                        $task | Add-Member -NotePropertyName Synopsis -NotePropertyValue $synopsis
                    }
                    if ($null -eq $task.IsPhase) {

                        #! if the task was written as 'phase <name>' then the InvocationName
                        #! can be used to find it.  Add a property 'IsPhase' for easier sorting
                        $task | Add-Member -NotePropertyName IsPhase -NotePropertyValue (
                            ( $task.InvocationInfo.InvocationName -like 'phase' ) ? $true : $false
                        )
                    }
                    if ($null -eq $task.Path) {
                        $task | Add-Member -NotePropertyName Path -NotePropertyValue (
                            Get-Item $task.InvocationInfo.ScriptName
                        )
                    }
                    if ($null -eq $task.Line) {
                        $task | Add-Member -NotePropertyName Line -NotePropertyValue $task.InvocationInfo.ScriptLineNumber
                        $task.PSObject.TypeNames.Insert(0, 'InvokeBuild.TaskInfo')
                    }

                    if ((-not ($PSBoundParameters.ContainsKey('Name'))) -or
                        ($key -like $Name)) {
                        $task | Write-Output
                    }
                } else {
                    throw "No task with name $key"
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
