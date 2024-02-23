
param(

)

#Synopsis: Add a COMPONENT header to the markdown file
task add.component.heading {
    Import-Module 'C:\Users\TAldrich\projects\github\PSMarkdig\source\PSMarkdig' -Force
    $componentMap = @{}
    $BuildInfo | Foreach-Module {
        $config = $_
        $config.SourceInfo
        | Where-Object Type -Like 'function'
        | ForEach-Object {
            if (-not ([string]::IsNullorEmpty($_.Component))) {
                $componentMap.Add($_.Name, $_.Component)
            }
        }
    }

    foreach ($mdDoc in (Get-ChildItem -Path .\docs -Filter '*.md' -Recurse)) {
        # Check to see if Component heading already exists first
        $componentHeading = "`r`n## COMPONENT`r`n" | PSMarkdig\New-MarkdownElement

        logDebug "Markdown file $($mdDoc.BaseName)"

        if ($componentMap.ContainsKey( $mdDoc.BaseName  )) {
            $componentName = $componentMap[$mdDoc.BaseName]
            $componentText = "`r`n$componentName`r`n" | PSMarkdig\New-MarkdownElement

            $doc = PSMarkdig\Import-Markdown $mdDoc

            logDebug "- Adding Component $componentName"

            if ($null -ne $doc) {
                logDebug "- Imported markdown.  $($doc.Count) elements"

                $headings = PSMarkdig\Get-MarkdownHeading $doc
                if ($null -ne $headings) {
                    logDebug "  - There are $($headings.Count) headings"
                    $lastHeading = $headings | Select-Object -Last 1
                }

                try {
                    logDebug "- Adding $($componentHeading.GetType().FullName) to doc"

                    PSMarkdig\Add-MarkdownElement -Element $componentHeading -Document $doc -Before $lastHeading
                    logDebug "- Adding $($componentText.GetType().FullName) to doc"
                    PSMarkdig\Add-MarkdownElement -Element $componentText -Document $doc -Before $lastHeading

                    PSMarkdig\Write-MarkdownElement $doc | Set-Content $mdDoc -NoNewline
                } catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
                Remove-Variable componentHeading, componentText, doc
            }
        }
    }
}
