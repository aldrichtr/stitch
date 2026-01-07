
using namespace System.Text
using namespace System.Collections

function Convert-KeyToXPath {
    <#
    .SYNOPSIS
        Convert a Configuration key path to an XPath in PSDKitXML format
    #>
    [CmdletBinding()]
    param(
        # The key path to convert
        [Parameter(
            ValueFromPipeline
        )]
        [string]$Key
    )
    begin {
        $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    }
    process {
        $configFile = Resolve-ProfileConfigurationFile @PSBoundParameters

        if ($null -ne $configFile) {
            $startLevel = (($configFile.BaseName -replace '\.config$', '') -split '\.').Count
        }

        $xPath    = [StringBuilder]::new('Data')
        $parts    = [ArrayList]::new($Key -split '\.')
        [void]$parts.RemoveRange(0,$startLevel)
        $level    = 1
        foreach ($part in $parts) {
            $level++
            Write-Debug "Level ${level}: $part"
            #! in XPath, indexes are 1-based so first child is 1
            if ($part -match ('\d+')) {
                Write-Debug "- This is an array index"
                # depending on the type of values in the Array, the children
                # might be 'Table' if it is an array of hashtables, or
                [void]$xPath.Append("/Array//*[$part]")
            } else {
                [void]$xPath.AppendJoin('', '/Table/Item[@Key="',$part, '"]')
            }
        }
        $xPath.ToString()
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
    }
}
