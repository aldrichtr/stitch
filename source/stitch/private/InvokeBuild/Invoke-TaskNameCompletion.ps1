function Invoke-TaskNameCompletion {
    <#
    .SYNOPSIS
        A tab completion provider for task names
    #>
    param(
        [Parameter(
            Mandatory
        )]
        [ArgumentCompleter(
            {
                param(
                    $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters
                )
                $possibleValues = Invoke-Build ? | Select-Object -ExpandProperty Name

                if ($fakeBoundParameters.ContainsKey('Name')) {
                    $possibleValues | Where-Object {
                        $_ -like "$wordToComplete*"
                    }
                } else {
                    $possibleValues | ForEach-Object { $_ }
                }
            })]$Name
    )
}
