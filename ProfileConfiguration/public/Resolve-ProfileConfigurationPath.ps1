function Resolve-ProfileConfigurationPath {
    <#
    .SYNOPSIS
        Determine the path to the file based on several factors
    .DESCRIPTION
        `Resolve-ProfileConfigurationPath` uses:
        1. The value passed in to the Path Parameter
        2. The PS_PROFILE_CONFIG environment variable
        3. The default location:
           if $dotfiles is defined (globally in the profile)
               $dotfiles\configuration.psd1 or $dotfiles\config\*.config.psd1
           else
               powershell_profile_dir\configuration.psd1 or powershell_profile_dir\config\*.config.psd1

        if the PATH ends up being a directory, then each file in the directory should have a name like
        <namespace>.config.psd1.  the namespace becomes the "top-level key" in the configuration object
#>
    [CmdletBinding()]
    param(
        # Optionally load a different configuration
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Path
    )
    begin {
        $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
        $DEFAULT_CONFIG = @{
            FILE = 'configuration.psd1'
            DIR  = '.config'
            ENV  = 'PS_PROFILE_CONFIG'
        }
    }
    process {
        <#------------------------------------------------------------------
         1. look for the path setting
        ------------------------------------------------------------------#>

        # 1. The value passed by the Path Parameter always wins
        if ($PSBoundParameters['Path']) {
            Write-Debug '  Path set by parameter'

            # 2. The $DEFAULT_CONFIG.ENV environment variable
        } elseif ([System.Environment]::GetEnvironmentVariable($DEFAULT_CONFIG.ENV, 'User')) {
            Write-Debug '  Path set by environment variable'
            $Path = [System.Environment]::GetEnvironmentVariable($DEFAULT_CONFIG.ENV, 'User')

            # 3. Use the default
        } else {
            ## first, determine if the dotfiles path is set and if not, use the profile directory
            Write-Debug '  Path set using the defaults'
            if ( (-not($null -eq $dotfiles)) -and (Test-Path $dotfiles) ) {
                Write-Debug "  `$dotfiles is set and does exist"
                $configPath = $dotfiles
            } elseif (-not ([string]::IsNullOrEmpty($PwshHome))) {
                Write-Debug "  `$PwshHome is set and does exist"
                $configPath = $PwshHome
            } else {
                Write-Verbose "`$dotfiles is not set or does not exist.  Using powershell profile directory instead"
                $configPath = (Get-Item $PROFILE.ToString()).Directory.FullName
            }

            ## now, check for the default file and if not then the directory
            Write-Debug '  looking for default configuration file'
            $pathToFile = (Join-Path $configPath $DEFAULT_CONFIG.FILE)
            $pathToDir = (Join-Path $configPath $DEFAULT_CONFIG.DIR)
            if (Test-Path $pathToFile) {
                Write-Debug "  $pathToFile found"
                $Path = $pathToFile
            } elseif (Test-Path $pathToDir) {
                Write-Debug "  $pathToDir found"
                $Path = $pathToDir
            } else {
                Write-Error 'Could not find any configuration locations' -ErrorAction Stop
            }
        }
        Write-Debug "  Config file path is '$Path'"
    }
    end {
        try {
            Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
            $item = Get-Item $Path
            $item
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}
