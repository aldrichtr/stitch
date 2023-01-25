---
title: stitch Project
url: https://github.com/aldrichtr/stitch
version: 0.1
status: pre-release
---

## Synopsis

stitch is a collection of functions, Invoke-Build tasks, and templates designed to help authors of PowerShell
modules.

## Description

stitch is a *project management system*.  That means that in addition to building source files into a module, stitch
contains functions and tasks for many other aspects of developing and managing a project.  Like the java build
system [maven](https://maven.apache.org/guides/getting-started/index.html#what-is-maven), stitch is a tool to help
manage:

- Builds
- Documentation
- Reporting
- Dependencies
- SCMs
- Releases
- Distribution


stitch adds additional aliases to your build that let you control tasks in a easy to read way, creating a build
[DSL](https://en.wikipedia.org/wiki/Domain-specific_language)

for example:

To set a task to run after another:

```powershell
add.footer | after create.document
```

Additionally, stitch comes with a wide array of tasks.  All tasks have tests to improve their reliablity, and
good [documentation](docs/stitch/Tasks)

## Notes

stitch is built to work *within* [Invoke-Build](https://github.com/nightroman/Invoke-Build), which means that it can
be integrated into an existing project without disrupting your current workflow.
