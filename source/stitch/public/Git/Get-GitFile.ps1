function Get-GitFile {
    <#
    .SYNOPSIS
        Return a list of the files listed in git status
    #>
    [OutputType([System.IO.FileInfo])]
    [CmdletBinding()]
    param(
        # The type of files to return
        [Parameter(
        )]
        [ValidateSet(
            'Added', 'Ignored', 'Missing', 'Modified', 'Removed', 'Staged',
            'Unaltered', 'Untracked',
        'RenamedInIndex', 'RenamedInWorkDir', 'ChangedInIndex', 'ChangedInWorkDir')]
        [AllowNull()]
        [string]$Type
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

    }
    process {
        if ($PSBoundParameters.ContainsKey('Type')) {
            $status = Get-GitStatus | Select-Object -ExpandProperty $Type
        } else {
            $status = Get-GitStatus
        }

        $status | Select-Object -ExpandProperty FilePath | ForEach-Object {
                Get-Item (Resolve-Path $_) | Write-Output
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

