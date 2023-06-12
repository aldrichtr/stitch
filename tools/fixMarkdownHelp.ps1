(Get-Content (Get-EditorFile | expand Path) -Raw) -replace '(?sm)\#\# SYNTAX\r\n\r\n*```\r\n' , "## SYNTAX`r`n`r`n``````powershell`r`n"
