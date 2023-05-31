using namespace System.Diagnostics.CodeAnalysis


function Initialize-StitchProject {

    [Alias('Institchilize')]
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'high'
    )]
    [SuppressMessage('PSAvoidUsingWriteHost', '', Justification='Output of write operation should not be redirected')]
    param(
        # The directory to initialize the build tool in.
        # Defaults to the current directory.
        [Parameter(
        )]
        [string]$Destination,

        # Overwrite existing files
        [Parameter(
        )]
        [switch]$Force,

        # Do not output any status to the console
        [Parameter(
        )]
        [switch]$Quiet
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

    }
    process {
        if ([string]::IsNullorEmpty($Destination)) {
            Write-Debug "Setting Destination to current directory"
            $Destination = (Get-Location).Path
        }
        $possibleBuildConfigRoot = $Destination | Find-BuildConfigurationRootDirectory
        if (-not ([string]::IsNullorEmpty($possibleBuildConfigRoot))) {
            $buildConfigDir = $possibleBuildConfigRoot
        } else {
            $buildConfigDefaultDir = '.build'
        }
        #-------------------------------------------------------------------------------
        #region Gather info

        if (-not($Quiet)) {
            Write-StitchLogo -Size 'large'
        }

        New-StitchPathConfigurationFile -Force:$Force

        if (-not ([string]::IsNullorEmpty($buildConfigDir))) {
            "Found your build configuration directory '$(Resolve-Path $buildConfigDir -Relative)'"
        } else {
            $prompt = ( -join @(
                'What is the name of your build configuration directory? ',
                $PSStyle.Foreground.BrightBlack,
                " ( $buildConfigDefaultDir )",
                $PSStyle.Reset
                )
                )

            $ans = Read-Host $prompt
            if ([string]::IsNullorEmpty($ans)) {
                $ans = $buildConfigDefaultDir
            }
            $buildConfigDir = (Join-Path $Destination $ans)
        }

        #endregion Gather info
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Create directories
        Write-Debug "Create directories if they do not exist"
        Write-Debug "  - Looking for $buildConfigDir"
        if (-not(Test-Path $buildConfigDir)) {
            try {
                '{0} does not exist.  {1}Creating{2}' -f $buildConfigDir, $PSStyle.Foreground.Green, $PSStyle.Reset
                $null = mkdir $buildConfigDir -Force
            } catch {
                throw "Could not create Build config directory $BuildConfigDir`n$_"
            }
        }
        $profileRoot = $buildConfigDir | Find-BuildProfileRootDirectory
        if ($null -eq $profileRoot) {
            $profileRoot = (Join-Path $buildConfigDir 'profiles')
            try {
                '{0} does not exist.  {1}Creating{2}' -f $profileRoot, $PSStyle.Foreground.Green, $PSStyle.Reset
                $null = mkdir $profileRoot -Force
            } catch {
                throw "Could not create build profile directory $profileRoot`n$_"
            }
        }
        if (-not (Test-Path (Join-Path $profileRoot 'default'))) {
            '{0} does not exist.  {1}Creating{2}' -f 'default profile', $PSStyle.Foreground.Green, $PSStyle.Reset
        }
        $profileRoot | New-StitchBuildProfile -Name 'default' -Force:$Force
        Get-ChildItem (Join-Path $profileRoot 'default') -Filter "*.ps1" | Foreach-Object {
            $_ | Format-File 'CodeFormattingOTBS'
        }

        if (-not (Test-Path (Join-Path $Destination '.build.ps1'))) {
            '{0} does not exist.  {1}Creating{2}' -f 'build runner', $PSStyle.Foreground.Green, $PSStyle.Reset
        }
        $Destination | New-StitchBuildRunner -Force:$Force
        Get-ChildItem $Destination -Filter ".build.ps1" | Format-File 'CodeFormattingOTBS'

        #endregion Create directories
        #-------------------------------------------------------------------------------
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
