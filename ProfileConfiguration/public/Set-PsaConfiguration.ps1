
<# [markdown]

To set a value in a config using a value and a key:
- we need to know if we are setting an existing value such as:
  @{Name = foo} --> @{Name = bar}

  if this is the case then we can use Set-Psd to that specific item and
  it should be fine.

#>

function Set-PsaConfiguration {
    <#
    .SYNOPSIS
        Set a configuration item in the PSAnnex.ConfigurationStore
    .DESCRIPTION

    .EXAMPLE
        PS C:\> $repos | Set-PsaConfiguration 'github.repos'
    .EXAMPLE
        PS C:\> Set-PsaConfiguration 'github.repos' $repos
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
        <#------------------------------------------------------------------
          1.  Determine which file to set the new value in
        ------------------------------------------------------------------#>
        $configFile = Get-PsaConfigurationFile -Path:$Path -Key $Key
        if ($null -eq $configFile) {
            throw "Could not set configuration because no file was found for '$Key'"
        }
        <#------------------------------------------------------------------
          2.  Next, the key we are looking up in the file may have the file
              name in the path. for example:
              Key = github.label.
        ------------------------------------------------------------------#>
            Write-Debug "Key is set to '$Key'"
            # first remove the "file path" portion from the key
            $file_path = $configFile.BaseName -replace '\.config'
            Write-Debug "  removing $file_path from Key path"
            $config_path = $Key -replace "$file_path.", ''
            Write-Debug "  path we are looking for is $config_path"

            $xPath = $config_path | ConvertTo-XPath
            Write-Debug "   xpath now $xPath"

            Write-Verbose "Getting configuration item at '$xPath' in $($configFile.Name)"

            $xmlDoc = Import-PsdXml $configFile.FullName
            try {
                $xmlNode = $xmlDoc.SelectNodes($xPath)
                Write-Debug "Selected Node $($xmlNode.Name)"
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }

            if ($xmlNode.Name -in @('Item')) {}
            Write-Debug "  Setting the value $Value"
            Set-Psd -Xml $xmlDoc -Value $Value -XPath $xPath
            Write-Debug "  Writing back to $($configFile.FullName)"
            Export-PsdXml -Path $configFile.FullName -Xml $xmlDoc

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
    }
}
