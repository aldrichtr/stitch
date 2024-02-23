
# Synopsis: Format documentation with markdownlint
task invoke.markdownlint {
    $tempFile = [System.IO.Path]::GetTempFileName()
    $basedir = "$env:APPDATA\npm"
    $node = 'node.exe'
    $mdLintPath = "$basedir/node_modules/markdownlint-cli/markdownlint.js"

    if (Test-Path $mdLintPath) {

        [string[]]$argList = @()

        $argList += $mdLintPath
        $argList += '.\docs\stitch'
        $argList += '--fix'
        $argList += '--output'
        $argList += $tempFile
        $argList += '--json'
        $argList += '--quiet'
        logInfo "Calling markdownlint"
        & $node $argList

        $lintErrors = Get-Content $tempFile | ConvertFrom-Json
        if ($lintErrors.Count -gt 0) {
            foreach ($lintError in $lintErrors) {
                '{0}:{1} - {2}' -f $lintError.fileName , $lintError.lineNumber, $lineError.ruleDescription
            }
        }
        Remove-Item $tempFile

        logInfo "Markdown Errors: $($lintErrors.Count)"
    } else {
        throw "Markdownlint is not installed.  Run npm install -g markdownlint-cli"
    }
}
