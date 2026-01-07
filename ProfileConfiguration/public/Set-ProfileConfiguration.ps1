Function Set-ProfileConfiguration {
    <#
    .SYNOPSIS
        Set a configuration item in the profile config
    .EXAMPLE
        PS C:\> $repos | Set-ProfileConfiguration 'github.repos'
    .EXAMPLE
        PS C:\> Set-ProfileConfiguration 'github.repos' $repos
    #>
    [CmdletBinding()]
    param(
        # Provide a "key path" to the item in the configuration
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
            Position = 0,
            Mandatory
        )]
        [string]$Key,

        # The value to set the key to
        [Parameter(
            Position = 1,
            Mandatory,
            ValueFromPipeline
        )]
        [object]$Value,

        # Optionally load a different configuration
        [Parameter(
        )]
        [string]$Path
    )
    begin {
        $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    }
    process {
        $configFile = Resolve-ProfileConfigurationFile -Path:$Path -Key $Key
        if ([string]::IsNullOrEmpty($configFile)) {
            throw "Could not find a file for $Key"
        } else {
            Write-Debug "Key is set to '$Key'"
            # first remove the "file path" portion from the key
            $filePath = $configFile.BaseName -replace '\.config'
            Write-Debug "  removing $filePath from Key path"
            $configPath = $Key -replace "$filePath.", ''
            Write-Debug "  path we are looking for is $configPath"

            $parts = ($configPath -split '\.')
            if ($parts.Count -gt 0) {
                $xPath = '/Data'
                foreach ($p in $parts) {
                    $xPath += -join ( '/Table/Item[@Key="', $p, '"]' )
                    Write-Debug "   xpath now $xPath"
                }

                Write-Verbose "Getting configuration item at '$xPath' in $($configFile.Name)"

                $xmlDoc = Import-PsdXml $configFile.FullName
                $xmlNode = $xmlDoc.SelectNodes($xPath)
                Write-Debug '  Setting the value'
                Set-Psd -Xml $xmlDoc -Value $Value -XPath $xPath
                Write-Debug "  Writing back to $($configFile.FullName)"
                Export-PsdXml -Path $configFile.FullName -Xml $xmlDoc
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
    }
}
