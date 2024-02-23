---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Invoke-ReplaceToken

## SYNOPSIS
Replace a given string 'Token' with another string in a given file.

## SYNTAX

```
Invoke-ReplaceToken -In <String> [-Token] <String> [-With] <String> [[-Destination] <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -In
File(s) to replace tokens in

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath, Path

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Token
The token to replace, written as a regular-expression

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -With
The value to replace the token with

```yaml
Type: String
Parameter Sets: (All)
Aliases: Value

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Destination
The destination file to write the new content to
If destination is a directory, \`Invoke-ReplaceToken\` will put the content in a file named the same as
the input, but in the given directory

```yaml
Type: String
Parameter Sets: (All)
Aliases: Out

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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

## NOTES

## RELATED LINKS
