function Invoke-StitchTemplate {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Medium'
    )]
    param(

        # Specifies a path to the template source
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Source,

        # The directory to place the new file in
        [Parameter()]
        [string]$Destination,

        # The name of target file
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$Name,

        # The target path to write the template output to
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipelineByPropertyName
        )]
        [string]$Target,

        # Binding data to be given to the template
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [hashtable]$Data,

        # Overwrite the Target with the output
        [Parameter(
        )]
        [switch]$Force,

        # Return the path to the generated file
        [Parameter(
        )]
        [switch]$PassThru
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {

        if (-not ([string]::IsNullorEmpty($Source))) {
            if (-not (Test-Path $Source)) {
                throw "Template file $Source not found"
            }

            try {
                if ([string]::IsNullorEmpty($Data)) {
                    $Data = @{}
                }

                $Data['Name'] = $Name
                # Templates can use this to import/include  other templates
                $Data['TemplatePath'] = $Source | Split-Path -Parent


                $templateOptions = @{
                    Path = $Source
                }


                $templateOptions['Binding'] = $Data
                $templateOptions['Safe'] = $true

                Write-Debug "Converting template $Name with options"
                Write-Debug "Output of template to $Target"
                foreach ($option in $templateOptions.Keys) {
                    Write-Debug "  - $option => $($templateOptions[$option])"
                }
                if (-not ([string]::IsNullorEmpty($templateOptions.Binding))) {
                    Write-Debug "    - Bindings:"
                    foreach ($key in $templateOptions.Binding.Keys) {
                        Write-Debug "      - $key => $($templateOptions.Binding[$key])"
                    }
                }

                $verboseFile = [System.IO.Path]::GetTempFileName()
                <#
                EPS builds the templates using StringBuilder, and then "executes" them in a separate powershell
                instance. Because of that, some errors and exceptions dont show up, you just get no output.  To
                get the actual error, you need to see what the error of the scriptblock is.  It looks like there is
                an update on the [github repo](https://github.com/straightdave/eps) but it is not the released
                version

                ! So to confirm that the template functions correctly, check for content first
                #>
                $content = Invoke-EpsTemplate @templateOptions -Verbose 4>$verboseFile
                #! Check this here and use it after we are out of the try block
                $contentExists = (-not([string]::IsNullorEmpty($content)))
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }

            if ($contentExists) {
                $overwrite = $false
                if (Test-Path $Target) {
                    if (-not ($Force)) {
                        $writeErrorSplat = @{
                            Message = "$Target already exists.  Use -Force to overwrite"
                            Category = 'ResourceExists'
                            CategoryTargetName = $Target
                        }

                        Write-Error @writeErrorSplat
                    } else {
                        $overwrite = $true
                    }
                }

                if ($overwrite) {
                    Write-Debug "It does exist"
                    $operation = 'Overwrite file'
                } else {
                    Write-Debug 'It does not exist yet'
                    $operation = 'Write file'
                }

                if ($PSCmdlet.ShouldProcess($Target, $operation)) {
                    try {
                        $targetDir = $Target | Split-Path -Parent
                        if (-not (Test-Path $targetDir)) {
                            mkdir $targetDir -Force
                        }
                        $content | Set-Content $Target
                        if ($PassThru) {
                            $Target | Write-Output
                        }
                    } catch {
                        throw "Could not write template content to $Target`n$_"
                    }
                }
            } else {
                #-------------------------------------------------------------------------------
                #region Get template error
                Write-Debug "No content.  Getting inner error"
                $verboseOutput = [System.Collections.ArrayList]@(Get-Content $verboseFile)
                #! Replace the first and last lines with braces to make it a scriptblock so we can execute the inner content
                $null = $verboseOutput.RemoveAt(0)
                $null = $verboseOutput.RemoveAt($verboseOutput.Count - 1)

                $null = $verboseOutput.Insert( 0 , 'try {')
                $verboseOutput += @(
                    '} catch {',
                    'throw $_',
                    '}'
                )
                $stringBuilderScript = [scriptblock]::Create(($verboseOutput | Out-String))
                try {
                    Invoke-Command -ScriptBlock $stringBuilderScript
                } catch {
                    throw $_
                }
                #endregion Get template error
                #-------------------------------------------------------------------------------
            }
        } else {
            throw "No Source given to process"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
