---
document type: cmdlet
external help file: stitch-Help.xml
HelpUri: ''
Locale: en-US
Module Name: stitch
ms.date: 09-02-2025
PlatyPS schema version: 2024-05-01
title: Find-TableItem
---

# Find-TableItem

## SYNOPSIS

Recurse down into a nested table / array

## SYNTAX

### __AllParameterSets

```
Find-TableItem [[-Path] <string>] [[-Table] <ref>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Recurse dow the nested table / array creating the keys if they don't exist

## EXAMPLES

## PARAMETERS

### -Path

The dot-separated path to the value

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Table

The Configuration to update

```yaml
Type: System.Management.Automation.PSReference
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Management.Automation.PSReference

{{ Fill in the Description }}

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

