---
document type: cmdlet
external help file: stitch-Help.xml
HelpUri: ''
Locale: en-US
Module Name: stitch
ms.date: 09-02-2025
PlatyPS schema version: 2024-05-01
title: Import-StitchConfiguration
---

# Import-StitchConfiguration

## SYNOPSIS

Return the stitch configuration object.  Settings are combined from the system, user, and local scopes in
that order , unless overridden by the `-Scope` parameter.

## SYNTAX

### __AllParameterSets

```
Import-StitchConfiguration [[-Scope] <Scope>] [[-Key] <string>] [-AsHashtable] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

`Import-StitchConfiguration` is one function that is

## EXAMPLES

## PARAMETERS

### -AsHashtable

Optionally return the configuration as a hash table instead of a Stitch.ConfigurationInfo object.

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

### -Key

The path to the key in the configuration

```yaml
Type: System.String
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

### -Scope

Specifies the scope of the configuration to retrieve.
Valid values are 'Local', 'User', and 'System'.

```yaml
Type: Scope
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: false
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

-.
Starting at the "lowest" scope (System < User < Local), for each scope:
  - Build and merge the configuration for this scope : `Import-ScopeConfiguration`.
    - Build and merge the configuration for the profile at this scope : Import-ProfileConfiguration`
      -.
Get the list of profiles that must be merged at this scope : `Get-ProfileTree`
        -.
For each profile in the list, resolve the path to that profile's directory `Resolve-ProfilePath`
        -.
For each file in the resolved directory, convert and merge its contents into BuildConfig : `Convert-ConfigurationFile`


## RELATED LINKS

{{ Fill in the related links here }}

