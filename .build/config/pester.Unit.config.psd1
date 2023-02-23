@{
    Run          = @{
        # Defaut @('.')
        # Directories to be searched for tests, paths directly to test files, or combination of
        # both.'
        Path                   = @(
            './tests'
        )

        # Defaut @()
        # Directories or files to be excluded from the run.'
        ExcludePath            = @()

        # Defaut @()
        # ScriptBlocks containing tests to be executed.'
        ScriptBlock            = @()

        # Defaut @()
        # ContainerInfo objects containing tests to be executed.'
        Container              = @()

        # Defaut '.Tests.ps1'
        # Filter used to identify test files.'
        TestExtension          = '.Tests.ps1'

        # Defaut $false
        # Exit with non-zero exit code when the test run fails. When used together with Throw,
        # throwing an exception is preferred.'
        Exit                   = $false

        # Defaut $false
        # Throw an exception when test run fails. When used together with Exit, throwing an exception
        # is preferred.'
        Throw                  = $false

        # Defaut $false
        # Return result object to the pipeline after finishing the test run.'
        PassThru               = $false

        # Defaut $false
        # Runs the discovery phase but skips run. Use it with PassThru to get object populated with
        # all tests.'
        SkipRun                = $false

        # Defaut 'None'
        # Skips remaining tests after failure for selected scope, options are None, Run,
        # Container and Block.
        SkipRemainingOnFailure = 'None'
    }

    Filter       = @{
        # Defaut @()
        # Tags of Describe, Context or It to be run.
        Tag         = @('unit')

        # Defaut @()
        # Tags of Describe, Context or It to be excluded from the run.
        ExcludeTag  = @()

        # Defaut @()
        # Filter by file and scriptblock start line, useful to run parsed tests programatically to
        # avoid problems with expanded names. Example: ''C:\tests\file1.Tests.ps1:37''
        Line        = @()

        # Defaut @()
        # Exclude by file and scriptblock start line, takes precedence over Line.
        ExcludeLine = @()

        # Defaut @()
        # Full name of test with -like wildcards, joined by dot. Example: ''*.describe
        # Get-Item.test1''
        FullName    = @()

    }
    CodeCoverage = @{
        # Defaut $false
        # Enable CodeCoverage.
        Enabled               = $false

        # Defaut 'JaCoCo'
        # Format to use for code coverage report. Possible values: JaCoCo, CoverageGutters'
        OutputFormat          = 'JaCoCo'

        # Defaut 'coverage.xml'
        # Path relative to the current directory where code coverage report is saved.'
        OutputPath            = 'coverage.xml'

        # Defaut 'UTF8'
        # Encoding of the output file.'
        OutputEncoding        = 'UTF8'

        # Defaut @()
        # Directories or files to be used for codecoverage, by # Default the Path(s) from general
        # settings are used, unless overridden here.'
        Path                  = @()

        # Defaut $true
        # Exclude tests from code coverage. This uses the TestFilter from general configuration.'
        ExcludeTests          = $true

        # Defaut $true
        # Will recurse through directories in the Path option.'
        RecursePaths          = $true

        # Defaut 75
        # Target percent of code coverage that you want to achieve, # Default 75%.'
        CoveragePercentTarget = 75

        # Defaut $true
        # EXPERIMENTAL: When false, use Profiler based tracer to do CodeCoverage instead of using
        # breakpoints.'
        UseBreakpoints        = $true

        # Defaut $true
        # Remove breakpoint when it is hit.'
        SingleHitBreakpoints  = $true

    }

    TestResult   = @{
        # Defaut $false
        # Enable TestResult.'
        Enabled        = $false

        # Defaut 'NUnitXml'
        # Format to use for test result report. Possible values: NUnitXml, NUnit2.5 or JUnitXml'
        OutputFormat   = 'NUnitXml'

        # Defaut 'testResults.xml'
        # Path relative to the current directory where test result report is saved.'
        OutputPath     = 'testResults.xml'

        # Defaut 'UTF8'
        # Encoding of the output file.'
        OutputEncoding = 'UTF8'

        # Defaut 'Pester'
        # Set the name assigned to the root ''test-suite'' element.'
        TestSuiteName  = 'Pester'

    }

    Should       = @{
        # Defaut 'Stop'
        # Controls if Should throws on error. Use ''Stop'' to throw on error, or ''Continue'' to fail
        # at the end of the test.'
        ErrorAction = 'Continue'

    }

    Debug        = @{
        # Defaut $false
        # Show full errors including Pester internal stack. This property is deprecated, and if set
        # to true it will override Output.StackTraceVerbosity to ''Full''.'
        ShowFullErrors         = $false

        # Defaut $false
        # Write Debug messages to screen.'
        WriteDebugMessages     = $false

        # Defaut @(
        #    'Discovery'
        #    'Skip'
        #    'Mock'
        #    'CodeCoverage'
        # )
        # Write Debug messages from a given source, WriteDebugMessages must be set to true for this
        # to work. You can use like wildcards to get messages from multiple sources, as well as * to get
        # everything.'
        WriteDebugMessagesFrom = @(
            'Discovery'
            'Skip'
            'Mock'
            'CodeCoverage'
        )

        # Defaut $false
        # Write paths after every block and test, for easy navigation in VSCode.'
        ShowNavigationMarkers  = $true

        # Defaut $false
        # Returns unfiltered result object, this is for development only. Do not rely on this object
        # for additional properties, non-public properties will be renamed without previous notice.'
        ReturnRawResultObject  = $false
    }

    Output       = @{
        # Defaut 'Normal'
        # The verbosity of output, options are None, Normal, Detailed and Diagnostic.'
        Verbosity           = 'Detailed'

        # Defaut 'Filtered'
        # The verbosity of stacktrace output, options are None, FirstLine, Filtered and Full.'
        StackTraceVerbosity = 'None'

        # Defaut 'Auto'
        # The CI format of error output in build logs, options are None, Auto, AzureDevops and
        # GithubActions.'
        CIFormat            = 'Auto'
    }

    TestDrive    = @{
        # Defaut $true
        # Enable TestDrive.'
        Enabled = $true
    }

    TestRegistry = @{
        # Defaut $true
        # Enable TestRegistry.'
        Enabled = $true
    }
}
