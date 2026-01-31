---
description: Describes the way that the stitch module combines multiple files into a single configuration object
Locale: en-US
ms.date: 09/03/2025
online version: https://github.com/aldrichtr/stitch/doc/en-US/stitch/about_Configuration.md
schema: 2.0.0
title: about_Stitch_Configuration
---
# The Stitch Configuration System

## about_Stitch_Configuration

```
ABOUT TOPIC NOTE:
The first header of the about topic should be the topic name.
The second header contains the lookup name used by the help system.

IE:
# Some Help Topic Name
## SomeHelpTopicFileName

This will be transformed into the text file
as `about_SomeHelpTopicFileName`.
Do not include file extensions.
The second header should have no spaces.
```

## SHORT DESCRIPTION

The stitch configuration system provides the developer with multiple layers of configuration data, as well as providing
a means of having multiple profiles, each of which can either be independent or can inherit from another profile in
order to reduce code duplication.

## LONG DESCRIPTION

There are many processes in the lifecycle of development that require a configuration.  From paths, to file names, and
various individual variables that affect the output of functions and scripts, the build process, the testing process,
etc.

Some of these variables will be constant across all your projects, such as where source files are stored (like the
PowerShellPracticeAndStyle conventions of having a `public` and `private` directory), or parameters that are passed to a
function that is used to build the project.

Stitch takes the approach of building a "monolithic" configuration table at runtime, and then passing that to functions
and tasks as needed.  That table is built in a layered approach, each layer adding or modifying the table so that
customizations can be applied at the user level or the individual project level.



## Scopes

At the base layer, there is the `System` scope.  These are generic defaults that should apply broadly across all
projects.  In an enterprise environment, these can be corporate defaults.  Next at the `User` scope, these are settings
that apply across the individual`s projects.  Finally because some projects require special instructions, there is the
`Local` scope, which only apply to that specific project.


## Profiles

A profile is a specific set of options that are specified at runtime.  If no profile is specified, then the profile is
the `default` profile.  Profiles are a way of having multiple *stacks* of configuration items, that can either be
independent, or can inherit


# EXAMPLES

{{ Code or descriptive examples of how to leverage the functions described. }}

# NOTE

{{ Note Placeholder - Additional information that a user needs to know.}}

# TROUBLESHOOTING NOTE

{{ Troubleshooting Placeholder - Warns users of bugs}}

{{ Explains behavior that is likely to change with fixes }}

# SEE ALSO

{{ See also placeholder }}

{{ You can also list related articles, blogs, and video URLs. }}

# KEYWORDS

{{List alternate names or titles for this topic that readers might use.}}

- {{ Keyword Placeholder }}
- {{ Keyword Placeholder }}
- {{ Keyword Placeholder }}
- {{ Keyword Placeholder }}
