
#SYNOPSIS: PlatyPS does not add 'powershell' to the fenced code blocks.  This task does.
task convert.codeblocks.pwsh {
    foreach ($mdDoc in (Get-ChildItem -Path .\docs -Filter "*.md" -Recurse)) {
        $doc = Import-Markdown $mdDoc.FullName
        $blocks = $doc | Where-Object {
            $_.GetType().FullName -like 'Markdig.Syntax.FencedCodeBlock'
        }
        foreach ($block in $blocks) {
            if ([string]::IsNullOrEmpty($block.UnescapedInfo)) {
                $block.Info = 'powershell'
                $block.UnescapedInfo = 'powershell'
            }
        }
        logInfo "Setting codeblocks to powershell in $($mdDoc.Name)"
        $doc | Write-MarkdownElement | Set-Content $mdDoc.FullName -NoNewline
    }
}
