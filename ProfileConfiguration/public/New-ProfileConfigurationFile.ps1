function New-ProfileConfigurationFile {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    #>
    [CmdletBinding()]
    param(
        # The name of the new file
        [Parameter(
        )]
        [string]$Name
    )
    begin {
        $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
        $DEFAULT_FILENAME = '.config'
        $DEFAULT_EXTENSION = '.psd1'
    }
    process {
        # just in case the user gave us a file name with the default naming included

        if ($Name -match "$([regex]::Escape($DEFAULT_FILENAME))$([regex]::Escape($DEFAULT_FILENAME))$") {
            $fileName = $Name
        } elseif ($Name -match "$([regex]::Escape($DEFAULT_FILENAME))$") {
            $fileName = "$Name$DEFAULT_EXTENSION"
        } else {
            $fileName = (-join ($Name, $DEFAULT_FILENAME, $DEFAULT_EXTENSION))
        }

        $configDir = Resolve-ProfileConfigurationPath
        $newConfigFile = (Join-Path $configDir $fileName)

        if (Test-Path $newConfigFile) {
            throw "$newConfigFile already exists"
        } else {
            '@{}' | Set-Content $newConfigFile
            Write-Verbose "Created new config file $newConfigFile"
        }

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
    }
}
