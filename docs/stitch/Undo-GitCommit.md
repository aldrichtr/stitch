---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Undo-GitCommit

## SYNOPSIS
Reset the branch to before the previous commit

## SYNTAX

### Hard
```
Undo-GitCommit [-Hard] [<CommonParameters>]
```

### Soft
```
Undo-GitCommit [-Soft] [<CommonParameters>]
```

## DESCRIPTION
There are three types of reset:
but keep all the changes in the working directory
Without This is equivelant to \`git reset HEAD~1 --mixed

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Hard
Hard reset

```yaml
Type: SwitchParameter
Parameter Sets: Hard
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Soft
Soft reset

```yaml
Type: SwitchParameter
Parameter Sets: Soft
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
