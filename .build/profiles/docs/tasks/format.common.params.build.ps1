
# Synopsis: Remove the list of common parameters from the documentation
task format.common.params {
    $replacementText = "This cmdlet supports the common parameters.`nFor more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216)."
    foreach ($mdDoc in (Get-ChildItem -Path .\docs -Filter '*.md' -Recurse)) {
        logInfo "Replacing Common Parameters extra info in $($mdDoc.Name)"
        (get-content $mdDoc -Raw ) -replace [regex]::Escape(
            'This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).'
        ) , $replacementText | Set-Content $mdDoc -NoNewline
    }
}
