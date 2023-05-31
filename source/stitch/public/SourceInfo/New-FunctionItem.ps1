
function New-FunctionItem {
    <#
    .SYNOPSIS
        Create a new function source item in the given module's source folder with the give visibility
    .EXAMPLE
        $module | New-FunctionItem Get-FooItem public
    .EXAMPLE
        New-FunctionItem Get-FooItem Foo public
    #>
    [CmdletBinding()]
    param(
        # The name of the Function to create
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [string]$Name,

        # The name of the module to create the function for
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('ModuleName')]
        [string]$Module,

        # Visibility of the function ('public' for exported commands, 'private' for internal commands)
        # defaults to 'public'
        [Parameter(
            Position = 2
        )]
        [ValidateSet('public', 'private')]
        [string]$Visibility = 'public',

        # Code to be added to the begin block of the function
        [Parameter(
        )]
        [string]$Begin,

        # Code to be added to the process block of the function
        [Parameter(
        )]
        [string]$Process,

        # Code to be added to the End block of the function
        [Parameter(
        )]
        [string]$End,

        # Optionally provide a component folder
        [Parameter(
        )]
        [string]$Component,

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
        $projectPaths = Get-ProjectPath
        if ($null -ne $projectPaths) {
            if (-not ([string]::IsNullorEmpty($projectPaths.Source))) {
                if ($PSBoundParameters.ContainsKey('Module')) {
                    $modulePath = (Join-Path $projectPaths.Source $Module)
                }

                $filePath = (Join-Path -Path $modulePath -ChildPath $Visibility)

                if ($PSBoundParameters.ContainsKey('Component')) {
                    $filePath = (Join-Path $filePath $Component)
                    if (-not(Confirm-Path $filePath -ItemType Directory)) {
                        throw "Could not create source directory $filePath"
                    }
                }
                Write-Debug "  - filePath is $filePath"

                $options = @{
                    Type     = 'function'
                    Name     = $Name
                    Destination = $filePath
                    Data     = @{ 'Name' = $Name }
                    Force    = $Force
                    PassThru = $PassThru
                }

                if ($PSBoundParameters.ContainsKey('Begin')) {
                    $options.Data['Begin'] = $Begin
                }
                if ($PSBoundParameters.ContainsKey('Process')) {
                    $options.Data['Process'] = $Process
                }
                if ($PSBoundParameters.ContainsKey('End')) {
                    $options.Data['End'] = $End
                }
                try {
                    New-SourceItem @options
                } catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            } else {
                throw 'Could not resolve Source directory'
            }
        } else {
            throw 'Could not get project path information'
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
