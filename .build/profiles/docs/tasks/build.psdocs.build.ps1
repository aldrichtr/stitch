
task build.psdocs import.module.source, {

    Import-Module PSDocs
    $BuildInfo | Foreach-Module {
        $config = $_
        foreach ($name in (Get-Command -Module Infraspective | Select-Object -ExpandProperty Name)) {
            $cmd = (Get-Command $name | Select-Object -Property *)
            $help = (Get-Help $name -Full)
            $help | Add-Member -NotePropertyName 'ParameterSets' -NotePropertyValue $cmd.ParameterSets
            $help | Add-Member -NotePropertyName 'CommandParameters' -NotePropertyValue $cmd.Parameters

    }






        $doc_options = @{
            Path         = $config.Docs.Source
            InputObject  = $help
            OutputPath   = $config.Docs.New
            InstanceName = $name
        }

        Write-Build DarkBlue "Updating help for $name"
        Invoke-PSDocument @doc_options | Out-Null
    }
}
