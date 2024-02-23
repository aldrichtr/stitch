---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Add-GitFile

## SYNOPSIS

## SYNTAX

### asPath (Default)
```
Add-GitFile [[-Path] <String[]>] [-All] [-RepoRoot <String>] [-PassThru] [<CommonParameters>]
```

### asEntry
```
Add-GitFile [-Entry <RepositoryStatus[]>] [-All] [-RepoRoot <String>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Get-ChildItem *.md | function Add-GitFile
```

### EXAMPLE 2
```
Get-GitStatus | function Add-GitFile
```

## PARAMETERS

### -Entry
Accept a statusentry

```yaml
Type: RepositoryStatus[]
Parameter Sets: asEntry
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Paths to files to add

```yaml
Type: String[]
Parameter Sets: asPath
Aliases: PSPath

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -All
Add All items

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

### -RepoRoot
The repository root

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return objects to the pipeline

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

## NOTES

## RELATED LINKS
