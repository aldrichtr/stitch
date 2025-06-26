
function Get-MetadataComment {
    <#
    .SYNOPSIS
        Return the metadata stored in a special comment within the task file
    #>
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
        $dataPattern = '(?sm)---(?<data>.*?)---'
    }
    process {
        foreach ($file in $Path) {
            if ($file | Test-Path) {
                try {
                    $fileItem = Get-Item $file
                    $helpInfo = Get-Help -Name $fileItem.FullName -Full
                    if ($null -ne $helpInfo) {
                        if ($null -ne $helpInfo.alertSet) {
                            if (-not ([string]::IsNullorEmpty($helpInfo.alertSet.alert.Text))) {
                                $noteInfo = $helpInfo.alertSet.alert.Text
                                if ($noteInfo -match $dataPattern) {
                                    if ($Matches.data) {
                                        $dataText = $Matches.data
                                        $sb = [scriptblock]::Create($dataText)
                                        & $sb
                                    }
                                }
                            }
                        }
                    }
                }
                catch {
                    throw "Could not get path $file`n$_"
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
