---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Get-ModuleItem

## SYNOPSIS
Retrieve the modules in the given path

## SYNTAX

```
Get-ModuleItem [-Path] <String[]> [-AsHashTable] [<CommonParameters>]
```

## DESCRIPTION
Get-ModuleItem returns an object representing the information about the modules in the directory given in
Path.
It returns information from the manifest such as version number, etc.
as well as SourceItemInfo
objects for all of the source items found in it's subdirectories

## EXAMPLES

### EXAMPLE 1
```
Get-ModuleItem .\source
```

## PARAMETERS

### -Path
Specifies a path to one or more locations containing Module Source

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PSPath

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -AsHashTable
Optionally return a hashtable instead of an object

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Stitch.ModuleItemInfo
## NOTES

## RELATED LINKS

[Get-SourceItem]()

