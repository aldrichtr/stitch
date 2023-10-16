function Get-StitchTemplateMetadata {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $content = ($template | Get-Content -Raw)
        $null = $content -match '(?sm)---(.*?)---'
        if ($Matches.Count -gt 0) {
            Write-Debug "  - YAML header info found $($Matches.1)"
            $Matches.1 | ConvertFrom-Yaml | Write-Output
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
