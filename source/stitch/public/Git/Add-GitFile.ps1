
function Add-GitFile {
    <#
    .EXAMPLE
        Get-ChildItem *.md | function Add-GitFile
    .EXAMPLE
        Get-GitStatus | function Add-GitFile
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'asPath'
    )]
    param(
        # Accept a statusentry
        [Parameter(
            ParameterSetName = 'asEntry',
            ValueFromPipeline
        )]
        [LibGit2Sharp.RepositoryStatus[]]$Entry,

        # Paths to files to add
        [Parameter(
            Position = 0,
            ParameterSetName = 'asPath',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,


        # Add All items
        [Parameter(
        )]
        [switch]$All,

        # The repository root
        [Parameter(
        )]
        [string]$RepoRoot,

        # Return objects to the pipeline
        [Parameter(
        )]
        [switch]$PassThru
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if ($PSBoundParameters.ContainsKey('Entry')) {
            $PSBoundParameters['Path'] = @()
            Write-Debug '  processing entry'
            foreach ($e in $Entry) {
                Write-Debug "   - adding $($e.FilePath)"
                $PSBoundParameters['Path'] += $e.FilePath
            }
        }
        foreach ($file in $Path) {
            Add-GitItem (Resolve-Path $file -Relative)
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
