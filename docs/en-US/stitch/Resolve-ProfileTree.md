---
document type: cmdlet
external help file: stitch-Help.xml
HelpUri: ''
Locale: en-US
Module Name: stitch
ms.date: 09-02-2025
PlatyPS schema version: 2024-05-01
title: Resolve-ProfileTree
---

# Resolve-ProfileTree

## SYNOPSIS

Return an array of profiles that are parent <=> child

## SYNTAX

### __AllParameterSets

```
Resolve-ProfileTree [[-Name] <string>] [-Ascending] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function reads the profile structure file present in the scopes, and creates a list of profiles to be
imported.
 The main purpose of this function is to provide other functions the list of profiles that must be
loaded

## EXAMPLES

### EXAMPLE 1

$tree = Resolve-ProfileTree 'prod'

## PARAMETERS

### -Ascending

Return the list of profiles in order from child to parent instead of parent to child

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Name

Return the Configuration of a specific Profile

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: true
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

### System.String

{{ Fill in the Description }}

## OUTPUTS

## NOTES

Profiles defined at any level affect all levels.


## RELATED LINKS

{{ Fill in the related links here }}

