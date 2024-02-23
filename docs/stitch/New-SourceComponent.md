---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# New-SourceComponent

## SYNOPSIS
Add a new Component folder to the module's source

## SYNTAX

### public
```
New-SourceComponent [[-Name] <String>] [[-Module] <String>] [-PublicOnly] [<CommonParameters>]
```

### private
```
New-SourceComponent [[-Name] <String>] [[-Module] <String>] [-PrivateOnly] [<CommonParameters>]
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

### -Name
The name of the component to add

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

### -Module
The name of the module to add the component to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PublicOnly
Only add the component to the public functions

```yaml
Type: SwitchParameter
Parameter Sets: public
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrivateOnly
Only add the component to the private functions

```yaml
Type: SwitchParameter
Parameter Sets: private
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
