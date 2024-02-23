---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Merge-FileCollection

## SYNOPSIS

Merge an array of files into an existing collection, overwritting any that have the same basename

## SYNTAX

```
Merge-FileCollection [-Collection] <PSReference> [-UpdateFiles] <Array> [<CommonParameters>]
```

## DESCRIPTION

{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1

```
$updates | Merge-FileCollection [ref]$allFiles
```

### EXAMPLE 2

```
Get-ChildItem -Path . -Filter *.ps1 | Merge-FileCollection [ref]$allScripts
```

## PARAMETERS

### -Collection

The collection of files to merge the updates into

```yaml
Type: PSReference
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateFiles

The additional files to update the collection with

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

The collection is passed in by reference.
This is so that the collection is updated without having to
reapply the result.

## RELATED LINKS
