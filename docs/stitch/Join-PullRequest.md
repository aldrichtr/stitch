---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Join-PullRequest

## SYNOPSIS
Merge the current branch's pull request, then pull them into '$DefaultBranch' (usually 'main' or 'master')

## SYNTAX

```
Join-PullRequest [[-RepositoryName] <String>] [-DontDelete] [[-DefaultBranch] <String>] [<CommonParameters>]
```

## DESCRIPTION
Ensuring the current branch is up-to-date on the remote, and that it has a pull-request,
this function will then:
1.
Merge the current pull request
1.
Switch to the \`$DefaultBranch\` branch
1.
Pull the latest changes

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -RepositoryName
The name of the repository. 
Uses the current repository if not specified

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DontDelete
By default the remote and local branches are deleted if successfully merged. 
Add -DontDelete to
keep the branches

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DefaultBranch
The default branch.
usually 'main' or 'master'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
