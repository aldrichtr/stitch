---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Test-ProjectRoot

## SYNOPSIS
Test if the given directory is the root directory of a project

## SYNTAX

```
Test-ProjectRoot [[-Path] <String>] [[-Defaults] <String>] [[-Source] <String>] [[-Tests] <String>]
 [[-Staging] <String>] [[-Artifact] <String>] [[-Docs] <String>] [<CommonParameters>]
```

## DESCRIPTION
\`Test-ProjectRoot\` looks for "typical" project directories in the given -Path and returns true if at least
two of them exist.

Typical project directories are:
- A source directory (this may be controlled by the variable $Source)
- A staging directory (the variable $Staging)
- A tests directory (the variable $Tests)
- A artifact/output directory (the variable $Artifact)
- A documentation directory (the variable $Docs)

## EXAMPLES

### EXAMPLE 1
```
Test-ProjectRoot
```

Without a -Path, tests the current directory for default project directories

### EXAMPLE 2
```
$projectPath | Test-ProjectRoot
```

## PARAMETERS

### -Path
Optionally give a path to start in

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

### -Defaults
Powershell Data File with defaults

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
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
Position: 4
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
Position: 5
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
Position: 6
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
Position: 7
Default value: .\docs
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Defaults are:
- Source : .\source
- Staging : .\stage
- Tests : .\tests
- Artifact : .\out
- Docs : .\docs

## RELATED LINKS
