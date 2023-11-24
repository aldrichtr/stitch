
function Test-ContentChanged {
    <#
    .SYNOPSIS
        Compare the given path to a list of MD5 hashes to determine if files have changed
    .DESCRIPTION
        For each file in the given path, compare the current MD5 hash with the one stored in Checksum.  If they are
        the same, return $false, otherwise return $true (one or more files have changed)

    #>
    [OutputType('bool')]
    [CmdletBinding(
        DefaultParameterSetName = 'File'
    )]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        [Parameter(
            ParameterSetName = 'Array',
            Position = 0
        )]
        [PSTypeName('File.Checksum')][Object[]]$Checksums,

        # The file that contains the checksums (CSV format)
        [Parameter(
            ParameterSetName = 'File',
            Position = 0
        )]
        [string]$ChecksumFile
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $changedFiles = [System.Collections.ArrayList]::new()
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('ChecksumFile'))) {
            if (-not ($Checksums.Count -gt 0)) {
                throw "Checksums required. Either provide an array of 'File.Checksum' items, or a path to the checksum file"
            }
        } else {
            if (Test-Path $ChecksumFile) {
                $Checksums = (Import-Csv $ChecksumFile)
            } else {
                throw "$ChecksumFile is not a valid path"
            }
        }
        $ChecksumList = [System.Collections.ArrayList]::new($Checksums)

        $currentFiles = Get-ChildItem $Path -File -Recurse

        foreach ($file in $currentFiles) {
            $relative = [System.Io.Path]::GetRelativePath((Resolve-Path $Path), $file)

            $listItem = $ChecksumList | Where-Object Path -Like $relative

            if ($null -ne $listItem) {
                if ($file | Test-Checkpoint $listItem.Hash) {
                    [void]$ChecksumList.Remove($listItem)
                } else {
                    Write-Verbose "$relative has changed"
                    [void]$changedFiles.Add($file.FullName)
                }
            } else {
                Write-Verbose "$relative was added"
                [void]$changedFiles.Add($file.FullName)
            }
        }
    }
    end {
        #! if there are any files left in the list, then it was deleted. Output $true because content changed
        if ($ChecksumList.Count -gt 0) {
            $true | Write-Output
        } else {
            #! If any files were changed, output $true, otherwise $false
            ($changedFiles.Count -gt 0) | Write-Output
        }
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
