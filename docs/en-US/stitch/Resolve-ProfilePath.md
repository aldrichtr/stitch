---
document type: cmdlet
external help file: stitch-Help.xml
HelpUri: ''
Locale: en-US
Module Name: stitch
ms.date: 09-02-2025
PlatyPS schema version: 2024-05-01
title: Resolve-ProfilePath
---

# Resolve-ProfilePath

## SYNOPSIS

Resolve the Path to the given [Stitch.Profile] at the given Scope

## SYNTAX

### __AllParameterSets

```
Resolve-ProfilePath [[-Name] <string>] [[-Scope] <Scope>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function contributes to `Import-StitchConfiguration` and is not much use on its own.
It uses the Name of the profile and the Scope to determine the path to the folder that holds the configuration
files for the profile at the scope.
 It does not guarantee the path exists, and will return $null if not found

## EXAMPLES

## PARAMETERS

### -Name

The name of the profile to resolve.
 `default` if not specified.

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

### -Scope

The scope at which to look-up the profile

```yaml
Type: Scope
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
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

### System.String

{{ Fill in the Description }}

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

