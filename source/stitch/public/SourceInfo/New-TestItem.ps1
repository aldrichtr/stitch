function New-TestItem {
    <#
    .SYNOPSIS
        Create a test item from a source item using the test template
    #>
    [CmdletBinding()]
    param(
        # The SourceItemInfo object to create the test from
        [Parameter(
            ValueFromPipeline
        )]
        [PSTypeName('Stitch.SourceItemInfo')]
        [Object[]]$SourceItem,

        # Overwrite an existing file
        [Parameter(
        )]
        [switch]$Force,

        # Return the path to the generated file
        [Parameter(
        )]
        [switch]$PassThru
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $projectPaths = Get-ProjectPath
        if ($null -ne $projectPaths) {
            if (-not ([string]::IsNullorEmpty($projectPaths.Source))) {
                $relativePath = [System.IO.Path]::GetRelativePath(($projectPaths.Source), $SourceItem.Path)
                Write-Debug "Relative Source path is $relativePath"
                $filePath = $relativePath -replace [regex]::Escape($SourceItem.FileName) , ''
                Write-Debug "  - filePath is $filePath"
                $testName = "$filePath$([System.IO.Path]::DirectorySeparatorChar)$($SourceItem.BaseName).Tests.ps1"

                Write-Debug "Setting template Name to $testName"
                $options = @{
                    Type     = 'test'
                    Name     = $testName
                    Data     = @{ s = $SourceItem }
                    Force    = $Force
                    PassThru = $PassThru
                }
                try {
                    New-SourceItem @options
                } catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            } else {
                throw 'Could not resolve Source directory'
            }
        } else {
            throw 'Could not get project path information'
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
