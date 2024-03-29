function New-StitchConfigurationFile {
    <#
    .SYNOPSIS
        Create a configuration in the folder specified in Path.
    .EXAMPLE
        New-StitchConfigurationFile $BuildRoot\.stitch\profiles\site

        Creates the file $BuildRoot\.stitch\profiles\site\stitch.config.ps1
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

        # The name of the configuration file.
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
        $template = Get-StitchTemplate -Type 'install' -Name '.config.ps1'


        if ($null -ne $template) {
            $template.Destination = $Path
            if ($PSBoundParameters.ContainsKey('Name')) {
                $template.Name = $Name
            } else {
                $template.Name = 'stitch.config.ps1'
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
            throw 'Could not find the stitch configuration file template'
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
