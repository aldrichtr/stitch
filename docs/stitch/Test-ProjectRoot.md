---
external help file: stitch-help.xml
Module Name: stitch
online version: https://github.com/aldrichtr/stitch/main/blob/docs/stitch/Test-ProjectRoot.md
schema: 2.0.0
Version: 0.0.1
---

# Test-ProjectRoot

## SYNOPSIS

Test if the given directory is the root directory of a project

## SYNTAX

```powershell
Test-ProjectRoot [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

`Test-ProjectRoot` looks for "typical" project directories in the given -Path and returns true if at least
two of them exist.

Typical project directories are:

- A source directory (this may be controlled by the variable `$Source`)
- A staging directory (the variable `$Staging`)
- A tests directory (the variable `$Tests`)
- A artifact/output directory (the variable `$Artifact`)
- A documentation directory (the variable `$Docs`)

## EXAMPLES

### EXAMPLE 1: Test the current directory

```powershell
Test-ProjectRoot
```

Without a -Path, tests the current directory for default project directories

### EXAMPLE 2: Test a directory using the pipeline

```powershell
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

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`, `-InformationAction`,
`-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`, `-Verbose`, `-WarningAction`, and
`-WarningVariable`.  For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[String]

## OUTPUTS

[bool]

## NOTES

Defaults are:

```output
- Source   : .\source
- Staging  : .\stage
- Tests    : .\tests
- Artifact : .\out
- Docs     : .\docs
```

## RELATED LINKS

[Resolve-ProjectRoot](Resolve-ProjectRoot.md)
