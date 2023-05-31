
function Find-TodoItem {
    <#
    .SYNOPSIS
        Find all comments in the code base that have the 'TODO' keyword
    .DESCRIPTION
        Show a list of all "TODO comments" in the code base starting at the directory specified in Path
    .EXAMPLE
        Find-TodoItem $BuildRoot
    #>
    [OutputType('Stitch.SourceItem.Todo')]
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
        $todoPattern = '^(\s*)(#)?\s*TODO(:)?\s+(.*)$'
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        #TODO: To refine this we could parse the file and use the comment tokens to give to Select-String
        $results = Get-ChildItem $Path -Recurse | Select-String -Pattern $todoPattern -CaseSensitive -AllMatches

         foreach ($result in $results) {
            [PSCustomObject]@{
                PSTypeName = 'Stitch.SourceItem.Todo'
                Text = $result.Matches[0].Groups[4].Value
                Position = (-join ($result.Path, ':', $result.LineNumber))
                File = (Get-Item $result.Path)
                Line = $result.LineNumber
            } | Write-Output
        }
 #>
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
