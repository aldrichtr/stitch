---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Get-ParseToken

## SYNOPSIS
Return an array of Tokens from parsing a file

## SYNTAX

```
Get-ParseToken [[-Path] <String[]>] [-Type <PSTokenType>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Specifies a path to one or more locations.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PSPath

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Type
The type of token to return

```yaml
Type: PSTokenType
Parameter Sets: (All)
Aliases:
Accepted values: Unknown, Command, CommandParameter, CommandArgument, Number, String, Variable, Member, LoopLabel, Attribute, Type, Operator, GroupStart, GroupEnd, Keyword, Comment, StatementSeparator, NewLine, LineContinuation, Position

Required: False
Position: Named
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
