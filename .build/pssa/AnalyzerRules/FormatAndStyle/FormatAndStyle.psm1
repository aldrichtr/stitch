
using namespace System.Management.Automation.Language
using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic

function Measure-NamedBlockLowerCase {
    <#
    .SYNOPSIS
        Ensure Named script blocks (Begin, Process, etc...) are lowercase.
    .DESCRIPTION
        The named script block names should be lowercase.  This rule can auto-fix violations.

        **BAD**
        - Process {...}

        **GOOD**
        - process {...}
    #>
    [CmdletBinding()]
    [OutputType([Object[]])]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        $predicate = {
            param(
                [Parameter()]
                [Ast]$Ast
            )
            (($Ast -is [NamedBlockAst]) -and
             (-not $Ast.Unnamed) -and
             (-not ($Ast.Extent.Text -cmatch '^[a-z]')))
        }
    }
    process {
        try {
            $violations = $ScriptBlockAst.FindAll($predicate, $False)
            foreach ($violation in $violations) {
                $extent = $violation.Extent
                $correction = ( -join @(
                        $extent.Text[0].ToString().ToLower(),
                        $extent.Text.Substring(1)
                    ))
                $correction_extent = [CorrectionExtent]::new(
                    $extent.StartLineNumber,
                    $extent.EndLineNumber,
                    $extent.StartColumnNumber,
                    $extent.EndColumnNumber,
                    $correction,
                    '')
                $suggested_corrections = [System.Collections.ObjectModel.Collection]::new([CorrectionExtent])
                [void]$suggested_corrections.Add($correction_extent)
                [DiagnosticRecord[]]@{
                    Message              = 'Named script block names should be lowercase'
                    RuleName             = 'NamedBlockLowerCase'
                    Severity             = 'Warning'
                    Extent               = $extent
                    SuggestedCorrections = $suggested_corrections
                } | Write-Output
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}

function Measure-OperatorLowerCase {
    <#
    .SYNOPSIS
        Operators (-join, -split, etc...) should be lowercase.
    .DESCRIPTION
        Operators should not be capitalized.
        This rule can auto-fix violations.

        **BAD**
        - $Foo -Join $Bar
        **GOOD**
        - $Foo -join $Bar
    #>
    [CmdletBinding()]
    [OutputType([Object[]])]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        $predicate = {
            param(
                [Ast]$Ast
            )
            (($Ast -is [BinaryExpressionAst]) -and
            ($Ast.error_position.Text -cmatch '[A-Z]'))
        }
    }
    process {
        try {
            $violations = $ScriptBlockAst.FindAll($predicate, $False)

            foreach ($violation in $violations) {
                $extent = $violation.Extent
                $error_position = $violation.error_position
                $start_column_number = $extent.StartColumnNumber
                $start = $error_position.StartColumnNumber - $start_column_number
                $end = $error_position.EndColumnNumber - $start_column_number

                $correction = ( -join @(
                        $extent.Text.SubString(0, $start),
                        $error_position.Text.ToLower(),
                        $extent.Text.SubString($end)
                    ))

                $correction_extent = [CorrectionExtent]::new(
                    $extent.StartLineNumber,
                    $extent.EndLineNumber,
                    $start_column_number,
                    $extent.EndColumnNumber,
                    $correction,
                    ''
                    )
                $suggested_corrections = New-Object System.Collections.ObjectModel.Collection['CorrectionExtent']
                [Void]$suggested_corrections.Add($correction_extent)

                [DiagnosticRecord[]]@{
                    Message              = 'Operators should be lowercase'
                    RuleName             = 'OperatorLowerCase'
                    Severity             = 'Warning'
                    Extent               = $extent
                    SuggestedCorrections = $suggested_corrections
                } | Write-Output
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}

function Measure-ParameterAttributeIsFalse {
    <#
    .SYNOPSIS
        Ensure parameter attributes do not use '= $false'
    .DESCRIPTION
        Parameter attributes should be listed if they are true, and ommitted if they are false.
        This rule can auto-fix violations.

        **BAD**
        - [Parameter(
            Mandatory = $true
           )]
        - [Parameter(
            Mandatory = $false
           )]

        **GOOD**
        - [Parameter(
            Mandatory
           )]
        - [Parameter(
           )]
    #>
    [CmdletBinding()]
    [OutputType([Object[]])]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        $predicate = {
            param(
                [Parameter()]
                [Ast]$Ast
            )
            (
                ($Ast -is [NamedAttributeArgumentAst]) -and
                ($Ast.Parent.TypeName -like 'Parameter') -and
                ($Ast.Extent.Text -match '\w+\s*=\s*\$false')
            )
        }
    }
    process {
        try {
            $violations = $ScriptBlockAst.FindAll($predicate, $false)
            foreach ($violation in $violations) {
                $extent = $violation.Extent
                $correction = ''
                $correction_extent = [CorrectionExtent]::new(
                    $extent.StartLineNumber,
                    $extent.EndLineNumber,
                    $extent.StartColumnNumber,
                    $extent.EndColumnNumber,
                    $correction,
                    '')
                $suggested_corrections = New-Object System.Collections.ObjectModel.Collection['CorrectionExtent']
                [void]$suggested_corrections.Add($correction_extent)
                [DiagnosticRecord[]]@{
                    Message              = 'Parameter attributes should be ommitted if false'
                    RuleName             = 'ParameterAttributeIsFalse'
                    Severity             = 'Warning'
                    Extent               = $extent
                    SuggestedCorrections = $suggested_corrections
                } | Write-Output
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}

function Measure-ParameterAttributeIsTrue {
    <#
    .SYNOPSIS
        Ensure parameter attributes do not use '= $true'
    .DESCRIPTION
        Parameter attributes should be listed if they are true, and ommitted if they are false.
        This rule can auto-fix violations.

        **BAD**
        - [Parameter(
            Mandatory = $true
           )]
        - [Parameter(
            Mandatory = $false
           )]

        **GOOD**
        - [Parameter(
            Mandatory
           )]
        - [Parameter(
           )]
    #>
    [CmdletBinding()]
    [OutputType([Object[]])]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        $predicate = {
            param(
                [Parameter()]
                [Ast]$Ast
            )
            (
                ($Ast -is [NamedAttributeArgumentAst]) -and
                ($Ast.Parent.TypeName -like 'Parameter') -and
                ($Ast.Extent.Text -match '\w+\s*=\s*\$true')
            )
        }
    }
    process {
        try {
            $violations = $ScriptBlockAst.FindAll($predicate, $false)
            foreach ($violation in $violations) {
                $extent = $violation.Extent
                $correction_text = ( $extent.Text -replace '\s*=\s*\$true', '')
                $correction = $extent | New-PsScriptAnalyzerCorrectionExtent -ReplacementText $correction_text


                $options = @{
                    Message              = 'Parameter attributes should be set if true'
                    RuleName             = $PSCmdlet.MyInvocation.InvocationName
                    Severity             = 'Warning'
                    Extent               = $extent
                    SuppressionId        = $PSCmdlet.MyInvocation.InvocationName.Replace('Measure-', '')
                    SuggestedCorrections = $correction
                }
                New-PsScriptAnalyzerDiagnosticRecord @options | Write-Output
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}

function Measure-ParamKeywordLowerCase {
    <#
    .SYNOPSIS
        Ensure the param block keyword is lowercase with no trailing space.
    .DESCRIPTION
        The "p" of "param" should be lowercase and no space between 'param' and '('
        This rule can auto-fix violations.

        **BAD**
        - Param()
        - param ()

        **GOOD**
        - param()
    #>
    [CmdletBinding()]
    [OutputType([Object[]])]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        $predicate = {
            param(
                [Ast]$Ast
            )
            (($Ast -is [ParamBlockAst]) -and
             (-not ($Ast.Extent.Text -cmatch 'param\(')))
        }
    }
    process {
        try {
            $violations = $ScriptBlockAst.FindAll($predicate, $false)
            foreach ($violation in $violations) {
                $extent = $violation.Extent
                $correction = $extent.Text -replace '^Param\s*\(', 'param('

                $options = @{
                    TypeName     = $extent_type
                    ArgumentList = @($extent.StartLineNumber,
                        $extent.EndLineNumber,
                        $extent.StartColumnNumber,
                        $extent.EndColumnNumber,
                        $correction,
                        ''
                    )
                }
                $correction_extent = New-Object @options
                $suggested_corrections = New-Object System.Collections.ObjectModel.Collection['CorrectionExtent']
                [void]$suggested_corrections.Add($correction_extent)

                [DiagnosticRecord[]]@{
                    Message              = 'Param block keyword should be lowercase with no trailing spaces'
                    RuleName             = 'ParamKeywordLowerCase'
                    Severity             = 'Warning'
                    Extent               = $extent
                    SuggestedCorrections = $suggested_corrections
                } | Write-Output
            }
            return $results
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
