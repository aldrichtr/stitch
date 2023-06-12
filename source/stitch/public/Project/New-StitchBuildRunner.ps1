function New-StitchBuildRunner {
    <#
    .SYNOPSIS
        Create the main stitch build script
    .EXAMPLE
        New-StitchBuildRunner $BuildRoot

        Creates the file $BuildRoot\.build.ps1
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Low'
    )]
    param(
        # Specifies a path to the folder where the runbook should be created
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # The name of the main build script.
        [Parameter(
        )]
        [string]$Name,

        # Overwrite the file if it exists
        [Parameter(
        )]
        [switch]$Force
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $template = Get-StitchTemplate -Type 'install' -Name '.build.ps1'


        if ($null -ne $template) {
            $template.Destination = $Path
            if ($PSBoundParameters.ContainsKey('Name')) {
                $template.Name = $Name
            }

            if (Test-Path $template.Target) {
                if ($Force) {
                    if ($PSCmdlet.ShouldProcess($template.Target, 'Overwrite file')) {
                        $template | Invoke-StitchTemplate -Force
                    }
                } else {
                    throw "$($template.Target) already exists.  Use -Force to overwrite"
                }
            } else {
                $template | Invoke-StitchTemplate
            }
        } else {
            throw 'Could not find the stitch build script file template'
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
