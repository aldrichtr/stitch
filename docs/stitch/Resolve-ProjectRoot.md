---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Resolve-ProjectRoot

## SYNOPSIS
Find the root of the current project

## SYNTAX

```
Resolve-ProjectRoot [[-Path] <String>] [[-Depth] <Int32>] [[-Defaults] <String>] [[-Source] <String>]
 [[-Tests] <String>] [[-Staging] <String>] [[-Artifact] <String>] [[-Docs] <String>] [<CommonParameters>]
```

## DESCRIPTION
Resolve-ProjectRoot will recurse directories toward the root folder looking for a directory that passes
\`Test-ProjectRoot\`, unless \`$BuildRoot\` is already set

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Optionally set the starting path to search from

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath

Required: False
Position: 1
Default value: (Get-Location).ToString()
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Depth
Optionally limit the number of levels to seach

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 8
Accept pipeline input: False
Accept wildcard characters: False
```

### -Defaults
Powershell Data File with defaults

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
Default Source directory

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: .\source
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
Position: 5
Default value: .\tests
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
Position: 6
Default value: .\stage
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
Position: 7
Default value: .\out
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
Position: 8
Default value: .\docs
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[Test-ProjectRoot]()

