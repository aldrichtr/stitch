---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# ConvertFrom-ConventionalCommit

## SYNOPSIS
Convert a git commit message (such as from PowerGit\Get-GitCommit) into an object on the pipeline

## SYNTAX

```
ConvertFrom-ConventionalCommit [[-Message] <String>] [[-Sha] <Object>] [[-Author] <Object>]
 [[-Committer] <Object>] [<CommonParameters>]
```

## DESCRIPTION
A git commit message is technically unstructured text. 
However, a long standing convention is to structure
the message should be a single line title, followed by a blank line and then any amount of text in the body.
Conventional Commits provide additional structure by adding "metadata" to the title:

-
|        |\<------ title ----------------------| \<- 50 char or less
|        \<type\>\[optional scope\]: \<description\>
message
|        \[optional body\]                        \<- 72 char or less
|
|        \[optional footer(s)\]                   \<- 72 char or less
-
Recommended types are:
- build
- chore
- ci
- docs
- feat
- fix
- perf
- refactor
- revert
- style
- test

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Message
The commit message to parse

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Sha
{{ Fill Sha Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Author
{{ Fill Author Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Committer
{{ Fill Committer Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
