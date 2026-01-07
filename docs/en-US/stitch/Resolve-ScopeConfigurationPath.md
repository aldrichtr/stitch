---
document type: cmdlet
external help file: stitch-Help.xml
HelpUri: ''
Locale: en-US
Module Name: stitch
ms.date: 09-02-2025
PlatyPS schema version: 2024-05-01
title: Resolve-ScopeConfigurationPath
---

# Resolve-ScopeConfigurationPath

## SYNOPSIS

Return the path that stitch looks to for configuration files at this scope

## SYNTAX

### __AllParameterSets

```
Resolve-ScopeConfigurationPath [[-Scope] <Scope>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

`Resolve-ScopeConfigurationPath` Returns the path to the `config` folder in the .stitch folder in each location.

## EXAMPLES

### EXAMPLE 1

Resolve-ScopeConfigurationPath

`.stitch`

### EXAMPLE 2

Resolve-ScopeConfigurationPath | Select-Object -ExpandProperty System

`C:\ProgramData\stitch`

## PARAMETERS

### -Scope

The scope at which to look-up the profile

```yaml
Type: Scope
DefaultValue: Local
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

### Scope

{{ Fill in the Description }}

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

