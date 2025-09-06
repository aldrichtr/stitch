Function Get-ProfileConfiguration {
    <#
    .SYNOPSIS
        Build a configuration object from one or more configuration files in psd1 format
    .DESCRIPTION

    .EXAMPLE
    #>
    [CmdletBinding()]
    param(
        # Optionally load a different configuration.  Note that if this parameter
        # is set, it is passed to `Resolve-ProfileConfigurationPath`
        [Parameter(
            ValueFromPipeline
        )]
        [string]$Path,

        # Optionally provide a "key path" to the item in the configuration
        # Example:
        # if the config is like:
        # @{
        #    'github' = @{
        #        'repository = @{
        #            ...
        #        }
        #    }
        #    ....
        # then 'github.repository' will return an object starting at
        # the repository "key"
        [Parameter(
            Position = 1
        )]
        [string]$Key,

        # Optionally return a Hashtable instead of a 'Dotfiles.ConfigurationInfo' object
        [Parameter(
        )]
        [switch]$AsHashTable

    )
    begin {
        $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
        $configuration = @{}
        # nested config levels deeper than 3 are not supported
        # this.level.is.too.many
        $MAX_NEST_LEVEL = 3
    }
    process {
        <#------------------------------------------------------------------
          1.  Determine where the config file(s) are
        ------------------------------------------------------------------#>
        $ConfigPath = (Resolve-ProfileConfigurationPath -Path:$Path)

        if ($null -eq $ConfigPath) {
            $PSCmdlet.ThrowTerminatingError('No path was given for profile configuration')
        }

        <#------------------------------------------------------------------
         2.  Create the configuration hashtable from files
        ------------------------------------------------------------------#>

        if ($ConfigPath -is [System.IO.FileInfo]) {
            # if the path was to a single file, then just load that one.
            Write-Debug '  ConfigPath is a file'
            $configuration = Import-Psd -Unsafe -Path $ConfigPath
        } elseif ($ConfigPath -is [System.IO.DirectoryInfo]) {
            # if the path was to a directory, then we are expecting one or more
            # .config.psd1 files to be in there.  The names are significant as they
            # contribute to the "path" within the configuration object
            Write-Debug '  ConfigPath is a directory'

            Get-ChildItem -Path $ConfigPath -Filter '*.config.psd1' | ForEach-Object {
                $file = $_
                Write-Debug "  loading config in file '$($file.Name)'"
                <#------------------------------------------------------------------
                  determine the "path" that this file will nest into
                ------------------------------------------------------------------#>
                # get the significant portion of the name
                $conf_path = $file.BaseName -replace '\.config$', ''
                Write-Debug "  config path is : $conf_path"

                # it might be a nested path (up to MAX_NEST_LEVEL)
                if ($conf_path.IndexOf('.') -ge 0) {
                    Write-Debug '    config path has multiple levels'
                    $conf_parts = $conf_path -split '\.'
                    Write-Debug "     - $($conf_parts.Count) levels found"
                    if ($conf_parts.Count -gt $MAX_NEST_LEVEL) {
                        Write-Warning "Nested config files max depth is $MAX_NEST_LEVEL! not importing"
                        continue
                    }
                } else {
                    $conf_parts = @($conf_path)
                }

                # at this point conf_parts is an array of 1 or more "levels" to set
                # where to import the file into
                switch ($conf_parts.Count) {
                    1 {
                        $parent = $conf_parts[0]
                        Write-Debug "  Importing $($file.basename) at $parent"
                        $configuration[$parent] = Import-Psd -Unsafe -Path $file.FullName
                        continue
                    }
                    2 {
                        $parent = $conf_parts[0]
                        $child = $conf_parts[1]
                        Write-Debug "  Importing $($file.basename) at $parent/$child"
                        if (-not($configuration.ContainsKey($parent))) {
                            Write-Debug "   Creating item $parent"
                            $configuration[$parent] = @{}
                        }
                        $configuration[$parent][$child] = Import-Psd -Unsafe -Path $file.FullName
                        continue
                    }
                    3 {
                        $parent = $conf_parts[0]
                        $child = $conf_parts[1]
                        $sub = $conf_parts[2]
                        Write-Debug "  Importing $($file.basename) at $parent/$child/$sub"
                        if (-not($configuration.ContainsKey($parent))) {
                            Write-Debug "   Creating item $parent"
                            $configuration[$parent] = @{}
                        }
                        if (-not($configuration[$parent].ContainsKey($child))) {
                            Write-Debug "   Creating item $parent/$child"
                            $configuration[$parent][$child] = @{}
                        }
                        $configuration[$parent][$child][$sub] = Import-Psd -Unsafe -Path $file.FullName
                        continue

                    }
                }
            }
        } else {
            Write-Debug "  ConfigPath given is a $($ConfigPath.GetType())"
        }
        Write-Debug '  Completed building configuration hashtable'
        <#------------------------------------------------------------------
          3.  Only return the nested key if set
        ------------------------------------------------------------------#>
        if ($PSBoundParameters.ContainsKey('Key')) {
            Write-Debug "Getting configuration item at '$Key'"
            $current_hash = $configuration

            $itemTokens = $Key -split '\.'
            if ($itemTokens.Count -gt 0) {
                foreach ($token in $itemTokens) {
                    if ($current_hash.ContainsKey($token)) {
                        $current_hash = $current_hash[$token]
                    } else {
                        Write-Error "Configuration does not contain '$token' in '$Key'" -ErrorAction Stop
                    }
                }
                $configuration = $current_hash
            } else {
                Write-Error "'$Key' did not return any config items"
            }
        }
    }
    end {
        if ($AsHashTable) {
            $configuration | Write-Output
        } else {
            if ($configuration -is [hashtable]) {
                $configuration['PSTypeName'] = 'Dotfiles.ConfigurationInfo'
                [PSCustomObject]$configuration | Write-Output
            } elseif ($configuration.Count -gt 1) {
                foreach ($conf in $configuration) {
                    $conf['PSTypeName'] = 'Dotfiles.ConfigurationInfo'
                    [PSCustomObject]$conf | Write-Output
                }
            }
        }

        Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
    }
}
