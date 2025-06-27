
function ConvertFrom-NUnit {
    <#
    .SYNOPSIS
        Convert data in NUnit XML format into a test result object
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'asXml'
    )]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            ParameterSetName = 'asFile',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # The xml content in NUnit format
        [Parameter(
            ParameterSetName = 'asXml',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [xml]$Xml

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if ($PSCmdlet.ParameterSetName -like 'asFile') {
            [xml]$Xml = Get-Content $Path
        }

        # --------------------------------------------------------------------------------
        # #region Confirm format

        if ($null -eq $Xml.'test-results') {
            throw 'Content does not contain Test Results'
        }
        $testResults = $Xml.'test-results'
        $environment = $testResults.environment
        if ($null -eq $environment) {
            throw 'No environment information found in result'
        }


        #! Pester puts the entire result output into the 'test-results' node,
        #!   then all of the tests are under the 'test-suite'.results
        #!   finally, each file is added as a 'test-suite' nodes
        $resultsNode = $Xml.'test-results'.'test-suite'.results
        if ($null -eq $resultsNode) {
            throw 'No results node found in content'
        }
        $fileNodes = $resultsNode.SelectNodes('test-suite')
        if ($null -eq $fileNodes) {
            throw 'No test suites found within result'
        }

        # #endregion Confirm format
        # --------------------------------------------------------------------------------

        # --------------------------------------------------------------------------------
        # #region Environment info

        $runId = New-Guid

        $testRunDirectory = $environment.cwd
        $user = (@($environment.'user-domain' , $environment.user) -join '\')
        $machine = $environment.'machine-name'
        $TimeStamp = (Get-Date (@(
                    $testResults.date,
                    $testResults.time
                ) -join ' '))

        # #endregion Environment info
        # --------------------------------------------------------------------------------


        foreach ($fileNode in $fileNodes) {
            $fullPath = $fileNode.name
            $relativePath = [System.IO.Path]::GetRelativePath( $testRunDirectory, $fullPath)
            $fileResult = $fileNode.result

            $testCases = $fileNode.SelectNodes('//test-case')

            foreach ($testCase in $testCases) {
                $testInfo = @{
                    RunId = $runId
                    Timestamp = $TimeStamp
                    File = $relativePath
                    Name = $testCase.description
                    TestPath = $testCase.name
                    Executed = $testCase.executed
                    Result = $testCase.result
                    Time = $testCase.time
                }
                [PSCustomObject]$testInfo
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
