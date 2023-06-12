
function Resolve-ProjectRoot {
    <#
    .SYNOPSIS
        Find the root of the current project
    .DESCRIPTION
        Resolve-ProjectRoot will recurse directories toward the root folder looking for a directory that passes
        `Test-ProjectRoot`, unless `$BuildRoot` is already set

    .LINK
        Test-ProjectRoot
    #>
    [CmdletBinding()]
    param(
        # Optionally set the starting path to search from
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path = (Get-Location).ToString(),

        # Optionally limit the number of levels to seach
        [Parameter()]
        [int]$Depth = 8,

        # Powershell Data File with defaults
        [Parameter(
        )]
        [string]$Defaults,

        # Default Source directory
        [Parameter(
        )]
        [string]$Source = '.\source',

        # Default Tests directory
        [Parameter(
        )]
        [string]$Tests = '.\tests',

        # Default Staging directory
        [Parameter(
        )]
        [string]$Staging = '.\stage',

        # Default Artifact directory
        [Parameter(
        )]
        [string]$Artifact = '.\out',

        # Default Docs directory
        [Parameter(
        )]
        [string]$Docs = '.\docs'
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $level = 1
        $originalLocation = $Path | Get-Item
        $currentLocation = $originalLocation
        $driveRoot = $currentLocation.Root


        Write-Debug "Current location: $($currentLocation.FullName)"
        Write-Debug "Current root: $($driveRoot.FullName)"
    }
    process {
        $rootReached = $false
        if ($null -ne $BuildRoot) {
            Write-Debug "BuildRoot is set, using that"
            $BuildRoot | Write-Output
            break
        }
        #TODO: Here we could look for .build.ps1 as the root, or perhaps tie it to a repository by looking for .git/
        :location do {
            if ($null -ne $currentLocation) {
                $null = $PSBoundParameters.Remove('Path')
                if (Test-ProjectRoot @PSBoundParameters -Path $currentLocation.FullName) {
                    $rootReached = $true
                    Write-Debug "Project Root found : $($currentLocation.FullName)"
                    $currentLocation.FullName | Write-Output
                    break location
                } elseif ($level -eq $Depth) {
                    $rootReached = $true
                    throw "Could not find project root in $Depth levels"
                    break location
                } elseif ($currentLocation -like $driveRoot) {
                    $rootReached = $true
                    throw "$driveRoot reached looking for project root"
                    break location
                } else {
                    Write-Debug "  Level: $level - $($currentLocation.Name) is not the project root"
                }
            } else {
                $rootReached = $true
            }
            Write-Debug "Setting current location to Parent"
            $currentLocation = $currentLocation.Parent
            $level++
        } until ($rootReached)
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
