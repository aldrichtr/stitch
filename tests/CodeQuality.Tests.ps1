
BeforeDiscovery {
  #region Assertion functions
  function FollowRule {

    [CmdletBinding()]
    param(
      $ActualValue,
      $PSSARule,
      $CallerSessionState,
      [Switch]$Negate
    )
    begin {
      $AssertionResult = [PSCustomObject]@{
        Succeeded      = $false
        FailureMessage = ''
      }
    }
    process {
      if ( $ActualValue.RuleName -contains $PSSARule.RuleName) {
        $AssertionResult.Succeeded = $false
        $AssertionResult.FailureMessage = @"
`n$($PSSARule.Severity) - $($PSSARule.CommonName)
$($ActualValue.Message)
$($PSSARule.SuggestedCorrections)
"@
        # there may be several
        # lines that do not Rule$rule the rule, collect them all into one
        # error message
        $ActualValue | Where-Object {
          $_.RuleName -eq $PSSARule.RuleName
        } | ForEach-Object {
          $AssertionResult.FailureMessage += "'{0}' at {1}:{2}:{3}`n" -f
          $_.Extent.Text,
          $_.Extent.File,
          $_.Extent.StartLineNumber,
          $_.Extent.StartColumnNumber
        }
      } else {
        $AssertionResult.Succeeded = $true
      }
    }
    end {
      if ($Negate) {
        $AssertionResult.Succeeded = -not($AssertionResult.Succeeded)
      }
      $AssertionResult
    }
  }
  if ('Pass' -notin (Get-AssertionOperator | Select-Object -ExpandProperty Name)) {
      Add-AssertionOperator -Name 'Pass' -Test $Function:FollowRule
  }
  #endregion

  #region Collect source files
  $testsDirectory = $PSCommandPath | Split-Path | Get-Item
  if ($testsDirectory.Name -notlike 'tests') { throw 'CodeQuality Tests file is not in the tests directory' }

  $sourceDirectory = $testsDirectory -replace 'tests$', 'source'

  $fDirOptions = @{
    Path      = $sourceDirectory
    Recurse   = $true
    Directory = $true
    Include   = @('public', 'private')
  }
  $functionDirectories = Get-ChildItem @fDirOptions

  $functionFiles = [System.Collections.ArrayList]::new()
  foreach ($dir in $functionDirectories) {
    $fFileOptions = @{
      Path    = $dir
      Recurse = $true
      File    = $true
      Filter  = '*.ps1'
    }
    [void]$functionFiles.AddRange( (Get-ChildItem @fFileOptions) )

  }
  #endregion

  #region Collect analyzer rules
  $rulesOptions = @{
    Severity = @('Error', 'Warning', 'Information')
  }
  [System.Collections.ArrayList]$analyzerRules = Get-ScriptAnalyzerRule @rulesOptions |
    Where-Object RuleName -NotMatch '(^PSDSC)|Manifest'
  #endregion

  $data = @{
    Files = $functionFiles
    Rules = $analyzerRules
  }
}

$options = @{
  Tag     = @( 'cq', 'code-quality')
  Name    = 'SCENARIO The file <_.Name> is inspected for code quality'
  Foreach = $data
}

Describe @options {
  BeforeAll {
    $Files = $_.Files
    $Rules = $_.Rules
  }

  Context 'WHEN the file is parsed in the current environment' -Tag @('parse') -ForEach $Files {
    BeforeAll {
      $sourceFile = $_
      if ($sourceFile | Test-Path) {
        $tokens      = $null
        $parseErrors = $null
        $content     = (Get-Content $sourceFile -Raw)
        $results     = [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$tokens, [ref]$parseErrors)
        $predicate   = { param($Ast) $ast -is [System.Management.Automation.Language.FunctionDefinitionAst] }
        $functionAst = $results.Find($predicate, $false)
      } else {
        throw "Source file $sourceFile does not exist"
      }
    }

    #region Tests

    It 'THEN the file name (<_.BaseName>) should be the same as the function name' -Tag @('filename') {
      $functionAst.Name | Should -BeLike ($sourceFile | Split-Path -LeafBase)
    }

    It 'AND THEN it should parse without error' {
      $parseErrors | Should -BeNullOrEmpty
    }

    It 'AND THEN The command should be able to be referenced without error' {
      (Get-Command $functionAst.Name | Should -Not -BeNullOrEmpty)
    }

    It 'AND THEN parsing should produce an Ast Object' {
      $functionAst | Should -Not -BeNullOrEmpty
    }

    It 'AND THEN the object should be a FunctionDefinitionAst' {
      $functionAst | Should -BeOfType [System.Management.Automation.Language.FunctionDefinitionAst]
    }
    #endregion
  }

  Context 'When the file is analyzed by PSScriptAnalyzer' -Tag @( 'analyze' ) -ForEach $Files {
    BeforeAll {
      $sourceFile = $_
      $analysis = Invoke-ScriptAnalyzer -Path $sourceFile -IncludeRule $Rules
    }
    Context 'WHEN the <_.RuleName> rule is tested' -ForEach $Rules {
      BeforeAll { $rule = $_ }

      It 'THEN it should pass' {
        $analysis | Should -Pass $rule
      }
    }
  } # end analyze
} # end describe
