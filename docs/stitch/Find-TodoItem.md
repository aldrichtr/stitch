---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Find-TodoItem

## SYNOPSIS
Find all comments in the code base that have the 'TODO' keyword

## SYNTAX

```
Find-TodoItem [[-Path] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Show a list of all "TODO comments" in the code base starting at the directory specified in Path

## EXAMPLES

### EXAMPLE 1
```
Find-TodoItem $BuildRoot
```

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Stitch.SourceItem.Todo
## NOTES

## RELATED LINKS
