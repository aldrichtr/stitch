---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# New-FunctionItem

## SYNOPSIS
Create a new function source item in the given module's source folder with the give visibility

## SYNTAX

```
New-FunctionItem [-Name] <String> [-Module] <String> [[-Visibility] <String>] [-Begin <String>]
 [-Process <String>] [-End <String>] [-Component <String>] [-Force] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
$module | New-FunctionItem Get-FooItem public
```

### EXAMPLE 2
```
New-FunctionItem Get-FooItem Foo public
```

## PARAMETERS

### -Name
The name of the Function to create

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

### -Module
The name of the module to create the function for

```yaml
Type: String
Parameter Sets: (All)
Aliases: ModuleName

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Visibility
Visibility of the function ('public' for exported commands, 'private' for internal commands)
defaults to 'public'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Public
Accept pipeline input: False
Accept wildcard characters: False
```

### -Begin
Code to be added to the begin block of the function

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

### -Process
Code to be added to the process block of the function

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

### -End
Code to be added to the End block of the function

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

### -Component
Optionally provide a component folder

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

### -Force
Overwrite an existing file

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

### -PassThru
Return the path to the generated file

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
