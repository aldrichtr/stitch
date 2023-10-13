---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# ConvertFrom-CommentedProperty

## SYNOPSIS
Uncomment the given Manifest Item

## SYNTAX

```
ConvertFrom-CommentedProperty [-Path <String[]>] [[-Property] <String>] [<CommonParameters>]
```

## DESCRIPTION
In a typical manifest, unused properties are listed, but commented out with a '#'
like \`# ReleaseNotes = ''\`
Update-Metadata, Import-Psd and similar functions need to have these fields available.
\`ConvertFrom-CommentedProperty\` will remove the '#' from the line so that those functions can use the given
property

## EXAMPLES

### EXAMPLE 1
```
$manifest | ConvertFrom-CommentedProperty 'ReleaseNotes'
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
