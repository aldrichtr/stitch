---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Test-CommentedProperty

## SYNOPSIS
Test if the given property is commented in the given manifest

## SYNTAX

```
Test-CommentedProperty [-Path <String[]>] [[-Property] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
$manifest | Test-CommentedProperty 'ReleaseNotes'
```

## PARAMETERS

### -Path
Specifies a path to one or more locations.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PSPath

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Property
The item to uncomment

```yaml
Type: String
Parameter Sets: (All)
Aliases: PropertyName

Required: False
Position: 1
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
