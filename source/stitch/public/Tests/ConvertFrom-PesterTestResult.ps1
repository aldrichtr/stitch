
function ConvertFrom-PesterTestResult {
    <#
    .SYNOPSIS
        Convert a Pester Test Result object to a Stitch.TestResultInfo
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            ParameterSetName = 'asPath',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # CliXml content
        [Parameter(
            ParameterSetName = 'asXml',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [xml]$Xml,

        # The output of Invoke-Pester -PassThru
        [Parameter(
            ParameterSetName = 'asObject',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Pester.Run]$Results

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if ($PSBoundParameters.ContainsKey('Path')) {
            if ($Path | Test-Path) {
                $testResult = Import-Clixml $Path
            } else {
                throw "$Path is not a valid path"
            }
        } elseif ($PSBoundParameters.ContainsKey('Xml')) {
            try {
                $testResult = [System.Management.Automation.PSSerializer]::Deserialize( $Xml )
            } catch {
                throw "Could not import XML content`n$_"
            }
        } elseif ($PSBoundParameters.ContainsKey('Results')) {
            $testResult = $Results
        } else {
            throw "No content was given to convert"
        }


        if ($null -eq $testResult) {
            throw 'No containers found in test result'
        }
        if ($null -eq $testResult.Containers) {
            throw 'No containers found in test result'
        }
        if ($null -eq $testResult.Tests) {
            throw 'No tests found in test result'
        }

        <#------------------------------------------------------------------
          All checks completed, we should have a usable object now
        ------------------------------------------------------------------#>
        $files = $testResult.Containers

        foreach ($test in $testResult.Tests) {
            $currentFile = files
            | Where-Object {
                $_.Block -contains "[+] $($test.Path[0])"
            }
            if ($null -ne $currentFile) {
                if ($currentFile | Test-Path) {
                    $checkpoint = Checkpoint-File $currentFile
                }

            }
        }

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
