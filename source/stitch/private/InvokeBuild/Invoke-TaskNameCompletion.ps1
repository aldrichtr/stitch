
function Invoke-TaskNameCompletion {
    <#
    .SYNOPSIS
        Complete the given task name
    .NOTES
        The Parameter that uses this function must be named 'Name'
    #>
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )
    Write-Debug "Command $commandName parameter $parameterName with '$wordToComplete'"
    $possibleValues = (Invoke-Build ? | Select-Object -ExpandProperty Name)

    if ($fakeBoundParameters.ContainsKey('Name')) {
        $possibleValues | Where-Object {
            $_ -like "$wordToComplete*"
        }
    } else {
        $possibleValues | ForEach-Object { $_ }
    }
}
