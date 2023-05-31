
function New-SourceComponent {
    <#
    .SYNOPSIS
        Add a new Component folder to the module's source
    #>
    [CmdletBinding()]
    param(
        # The name of the component to add
        [Parameter(
            Position = 0
        )]
        [string]$Name,

        # The name of the module to add the component to
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Module,

        # Only add the component to the public functions
        [Parameter(
            ParameterSetName = 'public'
            )]
            [switch]$PublicOnly,

            # Only add the component to the private functions
            [Parameter(
            ParameterSetName = 'private'
        )]
        [switch]$PrivateOnly
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $possibleSourceFolder = $PSCmdlet.GetVariableValue('Source')
        if ($null -eq $possibleSourceFolder) {
            $projectSourcePath = Get-ProjectPath | Select-Object -ExpandProperty Source
            Write-Debug "Project path value for Source: $projectSourcePath"
        } else {
            Write-Debug "Source path set from `$Source variable: $Source"
            $projectSourcePath = $possibleSourceFolder
        }
        $moduleDirectory = (Join-Path $projectSourcePath $Module)
        Write-Debug "Module directory is $moduleDirectory"
        if ($null -ne $moduleDirectory) {
            if (-not ($PublicOnly)) {
                $privateDirectory = (Join-Path $moduleDirectory 'private')
                if (Test-Path $privateDirectory) {
                    $null = (Join-Path $privateDirectory $Name) | Confirm-Path -ItemType Directory
                } else {
                    throw "Could not find $privateDirectory"
                }
            }
            if (-not ($PrivateOnly)) {
                $publicDirectory = (Join-Path $moduleDirectory 'public')
                if (Test-Path $publicDirectory) {
                    $null = (Join-Path $publicDirectory $Name) | Confirm-Path -ItemType Directory
                } else {
                    throw "Could not find $publicDirectory"
                }
            }
        } else {
            throw "Module source not found : $moduleDirectory"
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
