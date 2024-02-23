---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Get-BuildConfiguration

## SYNOPSIS
Gather information about the project for use in tasks

## SYNTAX

```
Get-BuildConfiguration [[-Path] <String>] [-ConfigurationFiles <String[]>] [-Source <String>] [-Tests <String>]
 [-Staging <String>] [-Artifact <String>] [-Docs <String>] [<CommonParameters>]
```

## DESCRIPTION
\`Get-BuildConfiguration\` collects information about paths, source items, versions and modules that it finds
in -Path. 
Configuration information can be added/updated using configuration files.

## EXAMPLES

### EXAMPLE 1
```
Get-BuildConfiguration . -ConfigurationFiles ./.build/config
gci .build\config | Get-BuildConfiguration .
```

## PARAMETERS

### -Path
Specifies a path to the folder to build the configuration for

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-Location)
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConfigurationFiles
Path to the build configuration file

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

### -Source
Default Source directory

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

### -Tests
Default Tests directory

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

### -Staging
Default Staging directory

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

### -Artifact
Default Artifact directory

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

### -Docs
Default Docs directory

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Collections.Specialized.OrderedDictionary
## NOTES

## RELATED LINKS
