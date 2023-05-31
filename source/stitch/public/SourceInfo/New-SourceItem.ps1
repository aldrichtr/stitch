
function New-SourceItem {
    <#
    .SYNOPSIS
        Create a new source item using templates
    .DESCRIPTION
        `New-SourceItem
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Low'
    )]
    param(
        # The type of file to create
        [Parameter(
            Position = 0
        )]
        [string]$Type,

        # The file name
        [Parameter(
            Position = 1
        )]
        [string]$Name,

        # The data to pass into the template binding
        [Parameter(
            Position = 2
        )]
        [hashtable]$Data,

        # The directory to place the new file in
        [Parameter()]
        [string]$Destination,

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
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        $template = Get-StitchTemplate -Type 'new' -Name $Type


        if ($null -ne $template) {
            if ($PSBoundParameters.ContainsKey('Name')) {
                $template.Name = $Name
            }
            if (-not ([string]::IsNullorEmpty($template.Extension))) {
                $template.Name = ( -join ($template.Name, $template.Extension))
            }

            if ($PSBoundParameters.ContainsKey('Destination')) {
                $template.Destination = $Destination
            }

            if ($PSBoundParameters.ContainsKey('Data')) {
                Write-Debug "Processing template Data"
                if (-not ([string]::IsNullorEmpty($template.Data))) {
                    Write-Debug "  - Updating Data"
                    $template.Data = ($template.Data | Update-Object $Data)
                } else {
                    Write-Debug "  - Setting Data"
                    $template.Data = $Data
                }
            }
            Write-Debug "Invoking template"
            $template | Invoke-StitchTemplate -Force:$Force -PassThru:$PassThru
        } else {
            throw "Could not find a 'new' template for type: $Type"
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }


} #close New-Sourceitem
