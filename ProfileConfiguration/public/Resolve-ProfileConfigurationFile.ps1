
function Resolve-ProfileConfigurationFile {
    [CmdletBinding()]
    param(
        # The key to look up for determining the file
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Key,

        # Optionally provide an alternate path to look in
        [Parameter(
        )]
        [string]$Path
    )
    begin {
        $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "  Looking for path to file that contains $Key"
        $ConfigPath = (Resolve-ProfileConfigurationPath -Path:$Path)
        if ($null -eq $ConfigPath) {
            $PSCmdlet.ThrowTerminatingError('No path was given for profile configuration')
        }

        if ($ConfigPath | Test-Path -PathType Leaf) {
            # if the path was to a single file, then just return that one.
            Write-Debug '  ConfigPath is a file'
            (Get-Item $ConfigPath) | Write-Output
        } elseif ($ConfigPath | Test-Path -PathType Container) {
            Write-Debug '  Configuration is in a directory, looking for files'
            $parts = [System.Collections.ArrayList]@($Key -split '\.')
            Write-Debug "  $Key has $($parts.Count) parts"

            $current = $parts.Clone()

            foreach ($part in $parts) {
                $fileName = "$($current -join '.').config.psd1"
                $filePath = (Join-Path $ConfigPath $fileName)
                Write-Debug "  Testing for $fileName"
                if (Test-Path $filePath) {
                    Write-Debug "   $fileName exists"
                    (Get-Item $filePath) | Write-Output
                    break
                } else {
                    Write-Debug "  $fileName not found"
                    $last = $current[-1]
                    Write-Debug "    removing $last"
                    $current.Remove($last)
                }
            }
            #? if we didn't find a file from the path, then what?

        } else {
            Write-Verbose "  Could not access $($ConfigPath.GetType()) $ConfigPath"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
    }
}
