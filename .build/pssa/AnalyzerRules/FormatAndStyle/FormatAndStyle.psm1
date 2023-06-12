
using namespace System.Management.Automation.Language
using namespace System.Collections.ObjectModel
using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer
using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic

function Measure-FunctionKeywordLowerCase {
    <#
    .SYNOPSIS
        Ensure the 'function' keyword is lowercase
    .DESCRIPTION
        The function keyword should be lowercase.  This rule can auto-fix violations.

        **BAD**
        - Function Verb-Noun {...}

        **GOOD**
        - function Verb-Noun {...}
    #>
    [CmdletBinding()]
    [OutputType([DiagnosticRecord[]])]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        $results = [DiagnosticRecord[]]@()
        $corrections = New-Object Collection['CorrectionExtent']

        $predicate = {
            param(
                [Parameter()]
                [Ast]$Ast
            )
            # Where the AST is a FunctionDefinitionAst
                (($Ast -is [FunctionDefinitionAst]) -and
            # and does not start with a lowercase letter
                (-not ($Ast.Extent.Text -cmatch '^function')))
        }
        $shouldSearchNested = $false
    }
    process {
        try {
            $violations = $ScriptBlockAst.FindAll($predicate, $shouldSearchNested )
            foreach ($violation in $violations) {
                $extent = $violation.Extent
                $corrections += ($extent | New-PSSACorrection -ReplacementText (
                        -join @(
                            $extent.Text[0].ToString().ToLower(),
                            $extent.Text.Substring(1)
                        ))
                )

                $options = @{
                    Message              = 'Function keyword should be lowercase'
                    Severity             = 'Warning'
                    Extent               = $extent
                    SuggestedCorrections = $corrections
                }
                $results += (New-PSSADiagnosticRecord @options)
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end {
        $results
    }
}

function Measure-NamedBlockLowerCase {
    <#
    .SYNOPSIS
        Ensure named script blocks (begin, process, end, clean) are lowercase.
    .DESCRIPTION
        The named script block names should be lowercase.  This rule can auto-fix violations.

        **BAD**
        - Process {...}
        - PROCESS {...}

        **GOOD**
        - process {...}
    #>
    [CmdletBinding()]
    [OutputType([DiagnosticRecord[]])]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        $results = [DiagnosticRecord[]]@()
        $corrections = New-Object Collection['CorrectionExtent']

        $predicate = {
            param(
                [Parameter()]
                [Ast]$Ast
            )
            # Where the AST is a NamedBlockAst
                (($Ast -is [NamedBlockAst]) -and
            # and is not Unnamed
                (-not $Ast.Unnamed) -and
            # and does not start with a lowercase letter
                (-not ($Ast.Extent.Text -cmatch 'begin|process|end|clean')))
        }
        $shouldSearchNested = $false
    }
    process {
        try {
            $violations = $ScriptBlockAst.FindAll($predicate, $shouldSearchNested )
            foreach ($violation in $violations) {
                $extent = $violation.Extent
                $corrections += ($extent | New-PSSACorrection -ReplacementText (
                            $extent.Text.ToString().ToLower()
                        )
                )

                $options = @{
                    Message              = 'Named script block names should be lowercase'
                    Severity             = 'Warning'
                    Extent               = $extent
                    SuggestedCorrections = $corrections
                }
                $results += (New-PSSADiagnosticRecord @options)
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end {
        $results
    }
}

function Measure-ParamKeywordLowerCaseNoSpace {
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
    [OutputType([DiagnosticRecord[]])]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        $results = [DiagnosticRecord[]]@()
        $corrections = New-Object Collection['CorrectionExtent']

        $predicate = {
            param(
                [Ast]$Ast
            )
            (($Ast -is [ParamBlockAst]) -and
             (-not ($Ast.Extent.Text -cmatch 'param\(')))
        }
        $shouldSearchNested = $false
    }
    process {
        try {
            $violations = $ScriptBlockAst.FindAll($predicate, $shouldSearchNested)
            foreach ($violation in $violations) {
                $extent = $violation.Extent
                $corrections += ($extent | New-PSSACorrection -ReplacementText (
                        $extent.Text -replace '^Param\s*\(', 'param('
                    )
                )

                $options = @{
                    Message              = 'Param block keyword should be lowercase with no trailing spaces'
                    Severity             = 'Warning'
                    Extent               = $extent
                    SuggestedCorrections = $corrections
                }
                $results += (New-PSSADiagnosticRecord @options)
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end {
        $results
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
    [OutputType([DiagnosticRecord[]])]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        $results = [DiagnosticRecord[]]@()
        $corrections = New-Object Collection['CorrectionExtent']
        $predicate = {
            param(
                [Parameter()]
                [Ast]$Ast
            )
            (
                # Where the AST is a Named Attribute Argument
                ($Ast -is [NamedAttributeArgumentAst]) -and
                # Of a Parameter
                ($Ast.Parent.TypeName -like 'Parameter') -and
                # That contains an '= $false' with or without spaces
                ($Ast.Extent.Text -match '\w+\s*=\s*\$false')
            )
        }
        $shouldSearchNested = $false
    }
    process {
        try {
            $violations = $ScriptBlockAst.FindAll($predicate, $shouldSearchNested)
            foreach ($violation in $violations) {
                $extent = $violation.Extent

                #TODO Need to find and remove the comma if it is there
                $corrections += ($extent | New-PSSACorrection -ReplacementText '')

                $options = @{
                    Message              = 'Parameter attributes should be ommitted if false'
                    Severity             = 'Warning'
                    Extent               = $extent
                    SuggestedCorrections = $correction
                }

                $results += (New-PSSADiagnosticRecord @options)

            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end {
        $results
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
    [OutputType([DiagnosticRecord[]])]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        $results = [DiagnosticRecord[]]@()
        $corrections = New-Object Collection['CorrectionExtent']

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
        $shouldSearchNested = $false
    }
    process {
        try {
            $violations = $ScriptBlockAst.FindAll($predicate, $shouldSearchNested)
            foreach ($violation in $violations) {
                $extent = $violation.Extent

                $corrections += ($extent | New-PssaCorrection -ReplacementText (
                        $extent.Text -replace '\s*=\s*\$true', ''
                    ))

                $options = @{
                    Message              = 'Parameter attributes are true if present'
                    Severity             = 'Warning'
                    Extent               = $extent
                    SuggestedCorrections = $corrections
                }
                $results += (New-PSSADiagnosticRecord @options)
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end {
        $results
    }
}

function Format-ParameterAttributeBlock {
    <#
    .SYNOPSIS
        Format a `[Parameter()]` block according to style rules
    .DESCRIPTION
        Parameter Arguments should be listed if they are true, and ommitted if they are false, and be listed in the
        following order:
        - ParameterSetName
        - Mandatory
        - Position
        - DontShow
        - ValueFromPipeline
        - ValueFromPipelineByPropertyName
        - ValueFromRemainingArguments
        - HelpMessage
        - HelpMessageBaseName
        - HelpMessageResourceId




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
    [OutputType([DiagnosticRecord[]])]
    param(
        [Parameter(
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]$ScriptBlockAst
    )
    begin {
        $results = [DiagnosticRecord[]]@()
        $corrections = New-Object Collection['CorrectionExtent']

        $ruleArgs = Get-RuleSetting

        #-------------------------------------------------------------------------------
        #region RuleSettings

        #-------------------------------------------------------------------------------
        #region defaults

        <#
         The default setting is to separate Arguments on separate lines:
         ParameterSetName = 'Default',
         Mandatory
        #>
        $newLine = "`n"

        <#
         The default is to omit the '= $true' expression on arguments
        #>
        $useTrueExpression = $false
        <#
         The default is to omit the argument if the expression is '= $false'
        #>
        $useFalseExpression = $false

        <#
         if useFalseExpression is $true,
         Exclude the following arguments if $false
        #>
        $excludeFalseExpression = @(
            'HelpMessage',
            'HelpMessageBaseName',
            'HelpMessageResourceId'
        )

        $argumentList = @(
            'ParameterSetName',
            'Mandatory',
            'Position',
            'DontShow',
            'ValueFromPipeline',
            'ValueFromPipelineByPropertyName',
            'ValueFromRemainingArguments',
            'HelpMessage',
            'HelpMessageBaseName',
            'HelpMessageResourceId'
        )
        #endregion defaults
        #-------------------------------------------------------------------------------

        if ($null -ne $ruleArgs) {
            # because the rule setting is 'useNewLine', if it is true (the default),
            # then Arguments are separated by new lines, if not, then use a space
            if (-not($ruleArgs.useNewLine)) {
                $newLine = ' '
            }
            if ($ruleArgs.ContainsKey('useTrueExpression')) {
                $useTrueExpression = $ruleArgs.useTrueExpression
            }
            if ($ruleArgs.ContainsKey('useFalseExpression')) {
                $useFalseExpression = $ruleArgs.useFalseExpression
            }
            if ($ruleArgs.ContainsKey('excludeFalseExpression')) {
                $excludeFalseExpression = $ruleArgs.excludeFalseExpression
            }
            # allow the user to re-order the arguments
            if ($ruleArgs.ContainsKey( 'argumentList' )) {
                $newList = $ruleArgs.argumentList

                if (($newList.Count -gt 0) -and ($newList.Count -lt 10)) {
                    # add any missing arguments to the bottom of the list
                    foreach ($a in $argumentList) {
                        # if the argument is not in the list already
                        if ($newList -notcontains $a) {
                            # if we are adding Falses
                            # but not if they are excluded
                            if (($useFalseExpression) -and ($excludeFalseExpression -notcontains $a)) {
                                $newList += $a
                            }
                        }
                    }
                }
                $argumentList = $newList
            }
        }
        $listJoinCharacter = ",$newLine"
        #endregion RuleSettings
        #-------------------------------------------------------------------------------

        function getIndent {
            param(
                [Parameter()]
                [string]$Argument,

                [Parameter()]
                [string]$Extent
            )
            foreach ($line in ($Extent -split "`n")) {
                if ($line -match "(?<indent>\s*)$Argument") {
                    $Matches.indent | Write-Output
                }
            }
        }

        $findParameter = {
            param(
                [Parameter()]
                [Ast]$Ast
            )
            (
                ($Ast -is [AttributeAst]) -and
                ($Ast.TypeName -like 'Parameter')
            )
        }
        $shouldSearchNested = $false
    }
    process {
        try {
            $parameterBlocks = $ScriptBlockAst.FindAll($findParameter, $shouldSearchNested)

            foreach ($parameterBlock in $parameterBlocks) {

                $extent = $parameterBlock.extent
                $replacementList = @()
                #! by looping through the argumentList, we can build the
                #! replacementList in order
                foreach ($argument in $argumentList) {
                    # is this argument even listed in the ScriptBlock?
                    $found = $parameterBlock.NamedArguments |
                        Where-Object ArgumentName -Like $argument
                    $indent = getIndent -Argument $argument -Extent $extent.Text
                    if ($null -ne $found) {
                        #yes, it is present
                        # - does it have an expression? (an '= ?')
                        if ($found.ExpressionOmitted -eq $false) {
                            # yes, it has an expression
                            # - is the expression '= $true'
                            if ($found.Argument -like '$true') {
                                # yes, the expression is '= $true'
                                #  - do we need to set it in the correction?
                                if ($useTrueExpression) {
                                    # yes, we need to set it
                                    $replacementList += "$indent$($found.ArgumentName) = `$true"
                                } else {
                                    # no, do not set it
                                    $replacementList += "$indent$($found.ArgumentName)"
                                }
                                # - is the expression '= $false' and do we need to set it?
                            } elseif ($found.Argument -like '$false') {
                                if ($useFalseExpression) {
                                    # yes, it is '= $false' and we need to set it
                                    $replacementList += "$indent$($found.ArgumentName) = `$false"
                                }
                                # - is the expression something other than '$true' and '= $false'
                            } else {
                                # yes, it is not true or false, we need to set it
                                $replacementList += "$indent$($found.ArgumentName) = $($found.Argument)"
                            }
                        } else {
                            # no, it does not have an expression
                            # - do we need to set the true expression?
                            if ($useTrueExpression) {
                                # yes, we need to set it
                                $replacementList += "$indent$($found.ArgumentName) = `$true"
                            } else {
                                # no, we do not need to set it
                                $replacementList += "$indent$($found.ArgumentName)"
                            }
                        }
                    } else {
                        # it was in the argumentList, but was not in the list of arguments
                        # in the scriptblock, so we add it here if we are using false
                        if ($useFalseExpression) {
                            $replacementList += "$($found.ArgumentName) = `$false"
                        }
                    }
                }
                # if the argument is in the scriptblock, and we are not setting false expressions
                # it is omitted

                # if the argument is in the scriptblock and it is not in the argumentList
                # it is omitted
                # TODO: is that ok?
                $head = [regex]::Escape('[Parameter(')
                $foot = [regex]::Escape(')]')
                $hindent = getIndent -Argument $head -Extent $extent.Text
                $findent = getIndent -Argument $foot -Extent $extent.Text

                $heading = "$hindent$head"
                $footing = "$findent$foot"
                $replacement = ( -join @(
                        $heading,
                        $newLine,
                    ($replacementList -join $listJoinCharacter),
                        $newLine,
                        $footing
                    ))
                    # Compare the two strings, disregard whitespace
                if (-not(Compare-Object $extent.Text.Trim() $replacement.Trim())) {
                    $corrections += ($extent | New-PssaCorrection -ReplacementText $replacement)

                    $options = @{
                        Message              = 'Parameter attributes are true if present false if not'
                        Severity             = 'Warning'
                        Extent               = $extent
                        SuggestedCorrections = $corrections
                    }
                    $results += (New-PSSADiagnosticRecord @options)
                }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end {
        $results
    }
}
