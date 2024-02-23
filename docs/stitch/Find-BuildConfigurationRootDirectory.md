---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Find-BuildConfigurationRootDirectory

## SYNOPSIS
Find the build configuration root directory for this project

## SYNTAX

```
Find-BuildConfigurationRootDirectory [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Find-BuildConfigurationRootDirectory -Path $BuildRoot
```

### EXAMPLE 2
```
$BuildRoot | Find-BuildConfigurationRootDirectory
```

## PARAMETERS

### -Path
Specifies a path to a location to look for the build configuration root

```yaml
Type: String
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

### System.IO.DirectoryInfo
## NOTES
\`Find-BuildConfigurationRootDirectory\` looks in the current directory of the caller if no Path is given

## RELATED LINKS
