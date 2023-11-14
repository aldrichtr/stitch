using namespace System.Management.Automation.Language
using namespace System.Collections.ObjectModel
using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer
using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic

function New-PSSACorrection {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'low'
    )]
    param(
        # The original extent
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [IScriptExtent]$Extent,

        [Parameter(
            Mandatory,
            Position = 0
        )]
        [AllowEmptyString()]
        [string]$ReplacementText,

        [Parameter(
        )]
        [string]$Path,

        [Parameter(
        )]
        [string]$Description
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        try {
            if (-not($PSBoundParameters.ContainsKey('Path'))) {
                $Path = ''
            }

            if (-not($PSBoundParameters.ContainsKey('Description'))) {
                $Description = ''
            }

            if ($PSCmdlet.ShouldProcess('Create Correction')) {
                $correctionExtent = New-Object CorrectionExtent -ArgumentList @(
                    $Extent.StartLineNumber,
                    $Extent.EndLineNumber,
                    $Extent.StartColumnNumber,
                    $Extent.EndColumnNumber,
                    $ReplacementText,
                    $Path,
                    $Description
                )

                $correctionExtent | Write-Output
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function New-PSSADiagnosticRecord {
    [OutputType([DiagnosticRecord])]
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'low'
    )]
    param(
        [Parameter(
        )]
        [string]$Message,

        [Parameter(
        )]
        [string]$RuleName,

        [Parameter(
        )]
        [DiagnosticSeverity]$Severity,

        [Parameter(
        )]
        [string]$ScriptPath,

        [Parameter(
        )]
        [string]$RuleSuppressionId,

        [Parameter(
        )]
        [IScriptExtent]$Extent,

        # parameter help description
        [Parameter(
        )]
        [Collection[CorrectionExtent]]$SuggestedCorrections
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $f = Get-PSCallStack | Select-Object -Skip 1 -First 1 | Format-RuleName
    }
    process {
        if (-not($PSBoundParameters.ContainsKey('RuleName'))) {
            $RuleName = $f.ShortName
        }

        if (-not($PSBoundParameters.ContainsKey('RuleSuppressionId'))) {
            $RuleSuppressionId = $f.ShortName
        }

        if (-not($PSBoundParameters.ContainsKey('Severity'))) {
            $Severity = Warning
        }

        if (-not($PSBoundParameters.ContainsKey('ScriptPath'))) {
            $ScriptPath = ''
        }
        try {

            $record = [DiagnosticRecord]@{
                Message              = $Message
                Extent               = $Extent
                RuleName             = $RuleName
                Severity             = $Severity
                ScriptPath           = $ScriptPath
                RuleSuppressionID    = $RuleSuppressionId
                SuggestedCorrections = $SuggestedCorrections
            }

            if ($PSCmdlet.ShouldProcess($RuleName, "Create Diagnostic Record")) {
                $record | Write-Output
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function Format-RuleName {
    [CmdletBinding()]
    param(
        # A function name from Get-PSCallStack
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string]$FunctionName
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $fullName = $FunctionName -replace '<.*>$', ''
        $verb, $noun = $fullName -split '-', 2

        switch -regex ($verb) {
            '^Format' {
                # A rule function that is intended to format PowerShell source
                switch -Regex ($noun) {
                    '^Place' { $shortName = $noun }
                    default {
                        $shortName = ($verb, $noun) -join ''
                    }
                }
            }
            '^Measure' {
                switch -Regex ($noun) {
                    default {
                        $shortName = $noun
                    }
                }
            }
        }
    }
    end {
        [PSCustomObject]@{
            FunctionName = $FunctionName
            FullName     = $fullName
            ShortName    = $shortName
            Verb         = $verb
            Noun         = $Noun
        }
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function Get-RuleSetting {
    [CmdletBinding()]
    param(
        # The name of the function used in the Settings File
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$FunctionName,

        # Return all settings
        [Parameter(
        )]
        [switch]$All
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $allSettings = [Helper]::Instance.GetRuleArguments()
        if ($null -ne $allSettings) {
            if ($All) {
                $allSettings | Write-Output
            } else {
                if ($PSBoundParameters.ContainsKey('FunctionName')) {
                    if ($FunctionName -match '(\w+)-(\w+)<\w+>') {
                        $FunctionName = Format-RuleName $FunctionName |
                            Select-Object -ExpandProperty ShortName
                    }
                } else {
                    $FunctionName = Get-PSCallStack | Select-Object -First 1 -Skip 1 |
                        Format-RuleName | Select-Object -ExpandProperty ShortName
                }

                if ($allSettings.ContainsKey($FunctionName)) {
                    $allSettings[$FunctionName] | Write-Output
                } else {
                    Write-Debug "No settings for $FunctionName were found"
                }

            }
        } else {
            Write-Debug 'Could not retrieve rule settings'
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
