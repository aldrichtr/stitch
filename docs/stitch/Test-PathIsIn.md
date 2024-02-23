---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Test-PathIsIn

## SYNOPSIS
Confirm if the given path is within the other

## SYNTAX

```
Test-PathIsIn -Path <String> [[-Parent] <String>] [-CaseSensitive] [<CommonParameters>]
```

## DESCRIPTION
\`Test-PathIsIn\` checks if the given path (-Path) is a subdirectory of the other (-Parent)

## EXAMPLES

### EXAMPLE 1
```
Test-PathIsIn "C:\Windows" -Path "C:\Windows\System32\"
```

### EXAMPLE 2
```
"C:\Windows\System32" | Test-PathIsIn "C:\Windows"
```

## PARAMETERS

### -Path
The path to test (the subdirectory)

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Parent
The path to test (the subdirectory)

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

### -CaseSensitive
Compare paths using case sensitivity

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

### System.Boolean
## NOTES

## RELATED LINKS
