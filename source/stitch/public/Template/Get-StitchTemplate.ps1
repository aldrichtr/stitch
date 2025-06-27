
function Get-StitchTemplate {
    [CmdletBinding()]
    param(
        # The type of template to retrieve
        [Parameter(
        )]
        [string]$Type,

        # The name of the template to retrieve
        [Parameter(
        )]
        [string]$Name
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $templatePath = (Join-Path (Get-ModulePath) 'templates')
    }
    process {
        $templateTypes = @{}
        Get-ChildItem $templatePath -Directory | ForEach-Object {
            Write-Debug "Found template file '$($_.Name)' Adding as $"
            $templateTypes.Add($_.BaseName, $_.FullName)
        }
        foreach ($templateType in $templateTypes.GetEnumerator()) {
            $templates = Get-ChildItem $templateType.Value -Filter '*.eps1' -File
            foreach ($template in $templates) {
                $templateObject = [PSCustomObject]@{
                    PSTypeName  = 'Stitch.TemplateInfo'
                    Type        = $templateType.Name
                    Source      = $template.FullName
                    Destination = ''
                    Name        = $template.BaseName -replace '_', '.'
                    Description = ''
                    Data        = @{}
                }

                $metaData = Get-StitchTemplateMetadata
                if ($null -ne $metaData) {
                    $null = $templateObject | Update-Object -UpdateObject $metaData
                }

                #-------------------------------------------------------------------------------
                #region Set Target

                #! Making this a ScriptProperty means that when Destination or Name are updated
                #! this value will be updated to reflect
                if ([string]::IsNullorEmpty($templateObject.Target)) {
                    $templateObject | Add-Member ScriptProperty -Name Target -Value {
                        if ([string]::IsNullorEmpty($this.Destination)) {
                            $this.Destination = (Get-Location)
                        }
                        (Join-Path ($ExecutionContext.InvokeCommand.ExpandString($this.Destination)) $this.Name)
                    }
                }
                #endregion Set Name
                #-------------------------------------------------------------------------------


                #-------------------------------------------------------------------------------
                #region Set destination

                if ([string]::IsNullorEmpty($templateObject.Target)) {
                    #TODO: I don't think this is right.  We should not be using 'path' for anything
                    if ($null -ne $templateObject.path) {
                        $templateObject.Destination = "$($templateObject.path)/$($templateObject.Target)"
                    }
                }

                #endregion Set destination
                #-------------------------------------------------------------------------------

                #-------------------------------------------------------------------------------
                #region Binding data
                if (-not ([string]::IsNullorEmpty($templateObject.bind))) {
                    $pathOptions = @{
                        Path = (Split-Path $template.FullName -Parent)
                        ChildPath = ($ExecutionContext.InvokeCommand.ExpandString($templateObject.bind))
                    }
                    $possibleDataFile = (Join-Path @pathOptions)
                    Write-Debug "Template has a bind parameter $possibleDataFile"
                    if (Test-Path $possibleDataFile) {
                        try {
                            $templateData = Import-Psd $possibleDataFile -Unsafe
                            $templateObject.Data = $templateObject.Data | Update-Object $templateData
                        }
                        catch {
                            throw "An error occurred updating $($templateObject.Name) template data`n$_"
                        }
                    }
                }
                #endregion Binding data
                #-------------------------------------------------------------------------------


                #-------------------------------------------------------------------------------
                #region Set display properties
                $defaultDisplaySet = 'Type', 'Name', 'Destination'
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $templateObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                #endregion Set display properties
                #-------------------------------------------------------------------------------

                #TODO: There is probably a better way to do this
                # if no parameters are set
                if ((-not ($PSBoundParameters.ContainsKey('Type'))) -and
                    (-not ($PSBoundParameters.ContainsKey('Name')))) {
                        $templateObject | Write-Output
                # if both are set and they match the object
                } elseif (($PSBoundParameters.ContainsKey('Type')) -and
                          ($PSBoundParameters.ContainsKey('Name'))) {
                    if (($templateObject.Type -like $Type) -and
                        ($templateObject.Name -like $Name)) {
                            $templateObject | Write-Output
                    }
                # if Type is set and it matches the object
                } elseif ($PSBoundParameters.ContainsKey('Type')) {
                    if ($templateObject.Type -like $Type) {
                        $templateObject | Write-Output
                    }
                # if Name is set and it matches the object
                } elseif ($PSBoundParameters.ContainsKey('Name')) {
                    if ($templateObject.Name -like $Name) {
                        $templateObject | Write-Output
                    }
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
