
function New-PsScriptAnalyzerCorrectionExtent {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [int]$StartLineNumber,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [int]$EndLineNumber,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [int]$StartColumnNumber,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [int]$EndColumnNumber,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$ReplacementText,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$Path,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$Description
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        try {
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent]$PSBoundParameters | Write-Output
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function New-PsScriptAnalyzerDiagnosticRecord {
    [CmdletBinding()]
    param(
        <#
        private IScriptExtent extent;
        private string ruleName;
        private DiagnosticSeverity severity;
        private string scriptPath;
        private string ruleSuppressionId;
        private IEnumerable<CorrectionExtent> suggestedCorrections;
        #>
        # Why this diagnostic was created.
        [Parameter(
        )]
        [string]$Message,

        # A span of text in the script
        [Parameter(
        )]
        [System.Management.Automation.Language.IScriptExtent]$Extent,

        # The name of the ScriptAnalyzer rule
        [Parameter(
        )]
        [string]$RuleName,

        # The severity level of the issue
        [Parameter(
        )]
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]$Severity,

        # Path to the script file
        [Parameter(
        )]
        [string]$ScriptPath,

        # The rule ID for this record
        [Parameter(
        )]
        [string]$SuppressionId,

        # Suggested correction to the extent
        [Parameter(
        )]
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent[]]$SuggestedCorrections
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        <#------------------------------------------------------------------
          Convert a list of CorrectionExtents into an ObjectModel collection
          before creating the Diagnostic Record
        ------------------------------------------------------------------#>
        if ($PSBoundParameters.ContainsKey('SuggestedCorrections')) {
            $corrections = New-Object System.Collections.ObjectModel.Collection['CorrectionExtent']
            foreach ($c in $SuggestedCorrections) {
                $corrections.Add($c)
            }
            $PSBoundParameters['SuggestedCorrections'] = $corrections
        }
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]$PSBoundParameters | Write-Output
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
