
enum LogLevel {
    TRACE = 6 # currently unused
    DEBUG = 5
    INFO  = 4
    WARN  = 3
    ERROR = 2
    FATAL = 1 # currently unused
}

function Write-BuildLog {
    [CmdletBinding(
        DefaultParameterSetName = 'dotnet'
    )]
    param(
        # The logging level of the message
        [Parameter(
            Position = 0
        )][LogLevel]$Level,

        # The text of the log message.  To send a formatted message, set the format fields
        # in the message and the replacement fields in Arguments
        # Write-BuildLog DEBUG -Message "The value of foo is {0}" -Arguments $foo
        [Parameter(
            Position = 1
        )][string]$Message,

        # The PSStyle color to print the Message in
        [Parameter(
        )][string]$MessageColor = 'White',

        # The format to write the datetime in the log message using .Net format specifiers
        [Parameter(
            ParameterSetName = 'dotnet'
        )][string]$TimestampFormat,

        # The format to write the datetime in the log message using UFormat specifiers
        [Parameter(
            ParameterSetName = 'unix'
        )][string]$TimestampUFormat,

        # The PSStyle color to print the timestamp in
        [Parameter(
        )][string]$TimestampColor = 'White',

        # The PSStyle color to print the level label in
        [Parameter(
        )][string]$LabelColor = 'White',

        [Parameter(
            ValueFromRemainingArguments
        )][array]$Arguments,

        # Optionally send the message (with arguments resolved) to the pipeline
        [Parameter(
        )][switch]$PassThru
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        #-------------------------------------------------------------------------------
        #region Timestamp

        if ($PSBoundParameters.ContainsKey('TimestampFormat')) {
            $timestamp = (Get-Date -Format $TimestampFormat)
        } elseif ($PSBoundParameters.ContainsKey('TimestampUFormat')) {
            $timestamp = (Get-Date -UFormat $TimestampUFormat)
        } else {
            $timestamp = (Get-Date -UFormat '%s')
        }
        #endregion Timestamp
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Console format
        $consoleFormat = New-Object System.Text.StringBuilder
        $null = $consoleFormat.Append('- ')

        #-------------------------------------------------------------------------------
        #region Timestamp style
        if ($PSBoundParameters.ContainsKey('TimestampColor')) {
            $null = $consoleFormat.Append( $PSStyle.Foreground.$TimestampColor )
        } elseif ($null -ne $Output.Timestamp.ForegroundColor) {
            $null = $consoleFormat.Append( $PSStyle.Foreground.($Output.Timestamp.ForegroundColor) )
        } else {
            #! The default is set in the parameter if it was not bound
            $null = $consoleFormat.Append( $PSStyle.Foreground.$TimestampColor )
        }
        $null = $consoleFormat.Append('{0,-10}:')
        $null = $consoleFormat.Append($PSStyle.Reset)
        $null = $consoleFormat.Append(' ')
        #endregion Timestamp style
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Label style
        if ($PSBoundParameters.ContainsKey('LabelColor')) {
            $null = $consoleFormat.Append( $PSStyle.Foreground.$LabelColor )
        } elseif ($null -ne $Output[[int]$Level].ForegroundColor) {
            $null = $consoleFormat.Append( $PSStyle.Foreground.($Output[[int]$Level].ForegroundColor) )
        } else {
            #! The default is set in the parameter if it was not bound
            $null = $consoleFormat.Append( $PSStyle.Foreground.$LabelColor )
        }

        $null = $consoleFormat.Append('[{1,-5}]')
        $null = $consoleFormat.Append($PSStyle.Reset)
        $null = $consoleFormat.Append(' ')
        #endregion Label style
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Message style
        if ($PSBoundParameters.ContainsKey('MessageColor')) {
            $null = $consoleFormat.Append( $PSStyle.Foreground.$MessageColor )
        } elseif ($null -ne $Output.Console.Message.ForegroundColor) {
            $null = $consoleFormat.Append( $PSStyle.Foreground.($Output.Console.Message.ForegroundColor) )
        } else {
            #! The default is set in the parameter if it was not bound
            $null = $consoleFormat.Append( $PSStyle.Foreground.$MessageColor )
        }
        $null = $consoleFormat.Append('{2}')
        $null = $consoleFormat.Append($PSStyle.Reset)
        #endregion Message style
        #-------------------------------------------------------------------------------
        #endregion Console format
        #-------------------------------------------------------------------------------

        $fileFormat = '- {0,-10}: [{1,-5}] {2}'

    }
    process {
        if($null -ne $Output) {
            if (($PSBoundParameters.ContainsKey('Arguments')) -and ($PSBoundParameters['Arguments'].Count -gt 0)) {
                $body = ($Message -f $Arguments)
            } else {
                $body = $Message
            }
            if ($Output.Console.Enabled) {
                $logMessage = ($consoleFormat.ToString() -f $timestamp, $Output[[int]$Level].Label, $body)
                [LogLevel]$configLevel = $Output.Console.Level
                if ($Output.ContainsKey($Task.Name)) {
                    #! override the default for this task
                    $configLevel = $Output[$Task.Name]
                }
                if ([int]$Level -le [int]$configLevel) {
                    Write-Debug "Writing to console at Level $Level"
                    #Write-Build $Color $logMessage
                    $logMessage
                }
            }
            if ($Output.File.Enabled) {
                $logMessage = $fileFormat -f $timestamp, $Output[[int]$Level].Label, $body
                [LogLevel]$configLevel = $Output.File.Level
                if ($Output.ContainsKey($Task.Name)) {
                    #! override the default for this task
                    $configLevel = $Output[$Task.Name]
                }
                if ([int]$Level -le [int]$configLevel) {
                    if ((-not([string]::IsNullOrEmpty($LogPath))) -and
                    (-not([string]::IsNullOrEmpty($LogFile)))) {
                        $BuildLog = (Join-Path $LogPath $LogFile)
                        if (-not(Test-Path $BuildLog)) {
                            #                            Write-Build DarkYellow "Creating directory $LogPath"
                            try {
                                $null = New-Item -Path $LogPath -ItemType Directory -Force
                                $null = New-Item -Path $LogPath -Name $LogFile -ItemType File
                            } catch {
                                throw "Could not create log file.$_"
                            }
                        }
                        $logMessage | Out-File $BuildLog -Force -Append -Encoding utf8
                    }
                }
            }
        }
        if ($PassThru) { $body | Write-Output }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function logDebug {
    param(
        [Parameter(
            Position = 0
        )][string]$Message,

        [Parameter(
            ValueFromRemainingArguments
        )][array]$Arguments
    )
    Write-BuildLog DEBUG @PSBoundParameters
}

function logInfo {
    param(
        [Parameter(
            Position = 0
        )][string]$Message,

        [Parameter(
            ValueFromRemainingArguments
        )][array]$Arguments
    )
    Write-BuildLog INFO @PSBoundParameters
}

function logWarn {
    param(
        [Parameter(
            Position = 0
        )][string]$Message,

        [Parameter(
            ValueFromRemainingArguments
        )][array]$Arguments
    )
    Write-BuildLog WARN @PSBoundParameters
}

function logError {
    param(
        [Parameter(
            Position = 0
        )][string]$Message,

        [Parameter(
            ValueFromRemainingArguments
        )][array]$Arguments
    )
    Write-BuildLog ERROR @PSBoundParameters
}

function logEnter {
    param(
        [Parameter(
            Position = 0
        )][string]$Message,

        [Parameter(
            ValueFromRemainingArguments
        )][array]$Arguments
    )
    #! override the default message color
    Write-BuildLog INFO @PSBoundParameters -LabelColor Cyan -MessageColor Cyan
}

function logExit {
    param(
        [Parameter(
            Position = 0
        )][string]$Message,

        [Parameter(
            ValueFromRemainingArguments
        )][array]$Arguments
    )
    #! override the default message color
    Write-BuildLog INFO @PSBoundParameters -LabelColor Cyan -MessageColor Cyan
}
