---
external help file: stitch-help.xml
Module Name: stitch
online version:
schema: 2.0.0
---

# Invoke-BuildNotification

## SYNOPSIS
Display a Toast notification for a completed build

## SYNTAX

```
Invoke-BuildNotification [[-Text] <String>] [[-Status] <String>] [[-LogFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Invoke-BuildNotification  -LogFile .\out\logs\build-20230525T2051223032Z.log -Status Passed
```

## PARAMETERS

### -Text
The text to add to the notification

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

### -Status
Build status

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

### -LogFile
Path to the log file

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
