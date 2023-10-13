---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Convert-LineEnding

## SYNOPSIS
Convert the line endings in the given file to "Windows" (CRLF) or "Unix" (LF)

## SYNTAX

### Unix (Default)
```
Convert-LineEnding [[-Path] <String[]>] [-LF] [<CommonParameters>]
```

### Windows
```
Convert-LineEnding [[-Path] <String[]>] [-CRLF] [<CommonParameters>]
```

## DESCRIPTION
\`Convert-LineEnding\` will convert all of the line endings in the given file to the type specified. 
If
'Windows' or 'CRLF' is given, all line endings will be '\r\n' and if 'Unix' or 'LF' is given all line
endings will be '\n'

'Unix' (LF) is the default

## EXAMPLES

### EXAMPLE 1
```
Get-ChildItem . -Filter "*.txt" | Convert-LineEnding -LF
```

Convert all txt files in the current directory to '\n'

## PARAMETERS

### -Path
The file to be converted

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PSPath

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -LF
Convert line endings to 'Unix' (LF)

```yaml
Type: SwitchParameter
Parameter Sets: Unix
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CRLF
Convert line endings to 'Windows' (CRLF)

```yaml
Type: SwitchParameter
Parameter Sets: Windows
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
WARNING!
this can corrupt a binary file.

## RELATED LINKS
