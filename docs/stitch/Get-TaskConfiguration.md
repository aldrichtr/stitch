---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Get-TaskConfiguration

## SYNOPSIS
Get the configuration file for the given task if it exists. 
First looks in the local user's stitch
directory, and then the local build configuration directory

## SYNTAX

```
Get-TaskConfiguration [[-Name] <String>] [[-TaskConfigPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Look for the given task's configuration in \`\<buildconfig\>/config/tasks\`

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
The task object

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

### -TaskConfigPath
{{ Fill TaskConfigPath Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
