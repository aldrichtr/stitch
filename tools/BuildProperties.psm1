

#-------------------------------------------------------------------------------
#region Parameter data

function Get-ParameterDataFile {
    '.\source\stitch\templates\install\parameters.psd1'
}

function Get-ParameterData {
    [CmdletBinding()]
    param(
        # Optionally provide the name of the parameter to get
        [Parameter(
        )]
        [string]$Name
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $buildParametersFile  = Get-ParameterDataFile
        $parameterData = Import-Psd $buildParametersFile -Unsafe
    }
    process {
        $groups = $parameterData.Parameters.Values

        foreach ($group in $groups) {
            $group | ForEach-Object {
                if ((-not($PSBoundParameters.ContainsKey('Name'))) -or
                    ($_.Name -like $Name)) {
                    $buildProperty = $_
                    $buildProperty.Add('PSTypeName', 'Build.PropertyInfo')
                    [PSCustomObject]$buildProperty | Write-Output
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

#endregion Parameter data
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#region Build properties

function Get-BuildScriptProperty {
    <#
    .SYNOPSIS
        Get all build properties set in BuildScripts.
    .DESCRIPTION
        Finds all properties set using 'Get-BuildProperty' and returns the property name, files, paths, and line numbers
        where it was found.  If -MissingOnly is given, only those properties that are not yet added to the parameters
        database for the templates.
    .NOTES
        This function relies on the property being set to use `Get-BuildProperty` vice the `property` alias
    #>
    [CmdletBinding()]
    param(
        # Only print parameters that are not in parameters file
        [Parameter()]
        [switch]$MissingOnly
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if ($MissingOnly) {
            $parameterData = Get-ParameterData
            $parameterList = ( $parameterData.Name )
        }
        $buildScriptDirectory = '.\source\stitch\BuildScripts'
        $options = @{
            Path    = $buildScriptDirectory
            Filter  = '*.ps1'
            Recurse = $true
        }
    }
    process {

        $buildPropertyMatches = Get-ChildItem @options | Select-String -Pattern '\s*Get-BuildProperty (\w+) (.+)$'

        'Found {0} matches' -f $buildPropertyMatches.Count | Write-Debug

        $buildParameters = @{}

        foreach ($match in $buildPropertyMatches) {
            $filePath = $match.Path
            $fileName = $match.Filename
            $lineNumber = $match.LineNumber
            $buildParameter = $match.Matches.Groups[1].Value
            $isListed = ($parameterList -contains $buildParameter)
            'In file {0}:{1} {2}' -f $fileName, $lineNumber, $buildParameter | Write-Debug
            if ((-not($MissingOnly)) -or (-not($isListed))) {
                if (-not($buildParameters.ContainsKey($buildParameter))) {
                    $buildParameters[$buildParameter] = @()
                }
                $buildParameters[$buildParameter] += [PSCustomObject]@{
                    PSTypeName = 'Build.PropertyInstanceInfo'
                    Path       = $filePath
                    File       = $fileName
                    Line       = $lineNumber
                }
            }
        }

        $buildParameters | Write-Output
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}


function Add-ParameterData {
    [CmdletBinding()]
    param(
        # The name of the parameter
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$Name,

        # The group the parameter belongs to
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$Group,

        # The type of parameter
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$Type,

        # The help message
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$Help,

        # The default value
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$Default
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $parameterData = Import-Psd -Path (Get-ParameterDataFile) -Unsafe
        $data = $PSBoundParameters
        if ($data.Keys -contains 'Debug') {
            [void]$data.Remove('Debug')
        }
        Write-Debug "This data is $($data | ConvertTo-Psd)"
        if ($parameterData.ContainsKey('Parameters')) {
            if ($parameterData.Parameters.Keys -contains $Group) {
                Write-Debug "Adding Parameter Data to $Group"
                $parameterData.Parameters[$Group] += $data
            } else {
                Write-Debug "No group '$Group' found"
                if (-not ($parameterData.Parameters.Keys -contains 'Other')) {
                    Write-Debug "Creating Group 'Other'"
                    $parameterData.Parameters['Other'] = @($data)
                } else {
                    $parameterData.Parameters['Other'] += $data
                }
            }
        } else {
            throw "malformed data in parameterData File"
        }
        $parameterDataFile = Get-ParameterDataFile
        #! I am not aware of a way to make ConvertTo-Psd output an ordered dictionary
        $psdContent = ($parameterData | ConvertTo-Psd)
        $psdContent = $psdContent -replace 'Parameters = \@', 'Parameters = [ordered]@'
        Write-Debug "Writing values to the file $parameterDataFile"
        $psdContent | Set-Content (Get-ParameterDataFile)
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
#endregion Build properties
#-------------------------------------------------------------------------------
