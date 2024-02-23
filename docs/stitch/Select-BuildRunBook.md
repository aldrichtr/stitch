---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Select-BuildRunBook

## SYNOPSIS
Locate the runbook for the given BuildProfile

## SYNTAX

```
Select-BuildRunBook [[-Path] <String[]>] [[-BuildProfile] <String>] [<CommonParameters>]
```

## DESCRIPTION
Select-BuildRunBook locates the runbook associated with the BuildProfile. 
If no BuildProfile is given,
Select-BuildRunBook will use default names to search for

## EXAMPLES

### EXAMPLE 1
```
$ProfilePath | Select-BuildRunBook 'default'
$ProfilePath | Select-BuildRunBook 'site'
```

## PARAMETERS

### -Path
Specifies a path to one or more locations.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PSPath

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -BuildProfile
The build profile to select the runbook for

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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
