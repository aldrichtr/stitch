
function Invoke-BuildNotification {
    <#
    .SYNOPSIS
        Display a Toast notification for a completed build
    .EXAMPLE
        Invoke-BuildNotification  -LogFile .\out\logs\build-20230525T2051223032Z.log -Status Passed
    #>
    [CmdletBinding()]
    param(
        # The text to add to the notification
        [Parameter(
        )]
        [string]$Text,

        # Build status
        [Parameter(
        )]
        [ValidateSet('Passed', 'Failed', 'Unknown')]
        [string]$Status,

        # Path to the log file
        [Parameter(
        )]
        [string]$LogFile
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $appImage = (Join-Path (Get-ModulePath) "spool-of-thread_1f9f5.png")
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        if (-not ($PSBoundParameters.ContainsKey('Text'))) {
            $Text = "Build Complete"
        }

        if ($PSBoundParameters.ContainsKey('Status')) {
            if ($Status -like 'Passed') {
                $Text = "`u{2705} $Text"
            } elseif ($Status -like 'Failed') {
                $Text = "`u{1f6a8} $Text"
            }
        } else {
            $Text = "`u{2754} $Text"
        }

        $toastOptions = @{
            Text = $Text
            AppLogo = $appImage
        }

        if ($PSBoundParameters.ContainsKey('LogFile')) {
            if (Test-Path $LogFile) {
                $logItem = Get-Item $LogFile
                $btnOptions = @{
                    Content = "Build Log"
                    ActivationType = 'Protocol'
                    Arguments = $logItem.FullName
                }

                $logButton = New-BTButton @btnOptions
                $toastOptions.Text = @($Text, "View the log file")
                $toastOptions.Button = $logButton
            }
        }


        New-BurntToastNotification @toastOptions


        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
