function Out-TaskHelp {
    [CmdletBinding()]
    param(
        [Parameter()][object]$TaskHelp
    )
    <# I used this to get the object instead of a formatted output
    ($TaskHelp) | Write-Output
    #>
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $sb = New-Object System.Text.StringBuilder
    }
    process {
        foreach($r in $TaskHelp.Task) {
            $null = $sb.AppendLine("# $($r.Name)")
            if ($r.Synopsis) {
                $null = $sb.AppendLine($r.Synopsis)
            }
        }

        $null = $sb.AppendLine('## Jobs')
        foreach($r in $TaskHelp.Jobs) {
            $null = $r.Location -match '(?<file>.*\.ps1):(?<ln>\d+)'
            if ($Matches.count -gt 0) {
                $file = (Get-Item $Matches.file)
                $null = $sb.AppendFormat('- `{0}` - {1}:{2:d2}', $r.Name, $file.Name, $Matches.ln).AppendLine()
            }
        }

        if ($TaskHelp.Parameters) {
            $null = $sb.AppendLine('## Parameters')
            foreach($param in $TaskHelp.Parameters) {
                $null = $sb.AppendFormat('- `[{0}]` **{1}**', $param.Type, $param.Name).AppendLine()
                if ($param.Description) {
                    $null = $sb.AppendLine().AppendFormat('  - {0}', $param.Description).AppendLine()
                }
            }
        }

        if ($TaskHelp.Environment) {
            $null = $sb.AppendLine('## Environment')
            foreach ($env in $TaskHelp.Environment) {
                $null = $sb.AppendFormat('- {0}' -f ($TaskHelp.Environment -join ', ')).AppendLine()
            }
        }
        $sb.ToString() | Show-Markdown
    }
    end {
        $null = $sb.Clear()
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
