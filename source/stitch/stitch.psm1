
using namespace System.Collections
using namespace System.Io

<#
.SYNOPSIS
  Generic Development-Mode PowerShell Script Module
.DESCRIPTION
  This module file is intended to be used during development to load all of the
  files in the directories in this module folder.
  By default, The module will "dotsource" all .ps1 files, "use" all .psm1 files,
  and "load" all .psd1 files in the source directories.
  The order of loading is the alphabetical sort that comes from a call to *Get-ChildItem*,
  unless a file named `LoadOrder.txt` is found in the same directory as this file.
  ## LOAD ORDER
  That file should list files, in the desired load order, blank lines and lines starting
  with a '#' are ignored.  Files should be listed as relative to this module file.  Once
  those files are loaded, the loading continues with any other files that were not already
  listed.
#>
#region Header
$private:templateInfo = @{
  Name     = 'Source module template'
  Version  = '0.7.1'
  Modified = '2025-06-11 18:01:56'
}

$private:modulePath = $PSCommandPath
$private:moduleName = ($private:modulePath | Split-Path -Leaf)


#! if debug was turned on, we need to see it and pass it into this scope
if ($global:DebugPreference -like 'Continue') {
  $script:DebugPreference = 'Continue'
  @(
        ('=' * 80),
    '= Debugging on ',
    "= Loading $private:moduleName from $private:modulePath"
        ('=' * 80)
    "= -- Using $($private:templateInfo.Name) $($private:templateInfo.Version) ($($templateInfo.Modified))"
        ('=' * 80)
  ) | Write-Debug
}
#endregion Header

#region Options

$private:sourceDirectories = @(
  'enum',
  'classes',
  'private',
  'public'
)

$private:formatsOptions = @{
  Path    = (Join-Path $PSScriptRoot 'formats')
  Filter  = '*.Formats.ps1xml'
  Recurse = $true
}

$private:typesOptions = @{
  Path    = (Join-Path $PSScriptRoot 'types')
  Filter  = '*.Types.ps1xml'
  Recurse = $true
}

$private:prefixFile = (Join-Path $PSScriptRoot 'prefix.ps1')
$private:suffixFile = (Join-Path $PSScriptRoot 'suffix.ps1')

$private:importOptions = @{
  Path        = $PSScriptRoot
  Filter      = '*.ps*1'
  Recurse     = $true
  ErrorAction = 'Stop'
}
#endregion Options

$private:exportedTypes = [ArrayList]::new()

[ArrayList]$private:sourceFiles = $private:sourceDirectories
| ForEach-Object {
  $private:importOptions.Path = (Join-Path $PSScriptRoot $_)
  Get-ChildItem @private:importOptions
  | ForEach-Object { [Path]::GetRelativePath($PSScriptRoot, $_ ) }
}

Write-Debug "$($sourceFiles.Count) Source files found"

#region Prefix file
if ($prefixFile | Test-Path) {
  Write-Debug "Loading prefix file $prefixFile"
  . $prefixFile
  [void]$sourceFiles.Remove([Path]::GetRelativePath($PSScriptRoot, $_))
}
#endregion Prefix file

#region Custom Load Order
if (Test-Path "$PSScriptRoot\LoadOrder.txt") {
  Write-Debug 'Using custom load order'
  try {
    foreach ($line in (Get-Content "$PSScriptRoot\LoadOrder.txt")) {
      switch -Regex ($line) {
        # blank line, skip
        '^\s*$' { continue }
        # Comment line, skip
        '^\s*#$' { continue }
        # load these
        '\.ps1$' {
          $filePath = (Join-Path $PSScriptRoot $line)
          if (Test-Path $filePath) {
            Write-Debug "Sourcing file $line"
            . $filePath
            $sourceFiles.Remove($line)
          }
          # TODO: What should we do if the file doesn't exist?
          continue
        }
        # modules get treated special
        '\.psm1$' {
          $filePath = (Join-Path $PSScriptRoot $line)
          if (Test-Path $filePath) {
            Write-Debug "Using the module $line"
            $useBlock = [scriptblock]::Create("using module $filePath")
            . $useBlock
          }
          $sourceFiles.Remove($line)
          continue
        }
        # manifest gets loaded
        '\.psd1$' {
          $filePath = (Join-Path $PSScriptRoot $line)
          if (Test-Path $filePath) {
            Write-Debug "Importing manifest $line"
            Import-Module $filePath -Global -Force
          }
          $sourceFiles.Remove($line)
        }
        #unrecognized, skip
        default { continue }
      } ## end switch
    } ## end ForEach

  } catch {
    Write-Error "Custom load order $_"
  }
}
#endregion Custom Load Order

Write-Debug "$($sourceFiles.Count) Source files found"

#region Load files
$private:remainingFiles = $sourceFiles.Clone()
try {
  foreach ($private:file in $remainingFiles) {
    $private:currentFile = (Join-Path $PSScriptRoot $file)
    if ($currentFile -match '\.ps1$') {
        Write-Debug "Sourcing file $file"
      . $currentFile
      [void]$sourceFiles.Remove($file)
    } elseif ($file -match '\.psm1$') {
        Write-Debug "Using module $($currentFile)"
      $private:useStmt = [scriptblock]::Create("using module $currentFile")
      . $useStmt
      if ($file -match '^class') {
        $private:typeName = (Get-Item $currentFile).BaseName
        Write-Debug "Adding type $typeName"
        $exportedTypes.Add($typeName)
      }
      [void]$sourceFiles.Remove($file)
    } elseif ($currentFile -match '\.psd1$') {
      Write-Debug "Importing manifest $currentFile"
      Import-Module $currentFile -Global -Force
      [void]$sourceFiles.Remove($file)
    } else {
      Write-Debug "Ignoring file $file"
    }
  } # end foreach remaining file
  if ($sourceFiles.Count -gt 0) {
    Write-Debug "Unprocessed files: $($sourceFiles -join ', ')"
  } else {
    Write-Debug "All files processed"
  }
} catch {
  throw "An error occurred during the processing of file '$file':`n$_"
}
#endregion Load files

#region Format files
if ($private:formatsOptions.Path | Test-Path) {
  foreach ($private:formatFile in (Get-ChildItem @private:formatsOptions)) {
    Write-Debug "Adding Formats from $($private:formatFile.Name)"
    Update-FormatData -AppendPath $private:formatFile.FullName
  }
}
#endregion Format files

#region Type files
if ($private:typesOptions.Path | Test-Path) {
  foreach ($private:typeFile in (Get-ChildItem @private:typesOptions)) {
    Write-Debug "Adding types from $($private:typeFile.Name)"
    Update-TypeData -AppendPath $private:typeFile
  }
}
#endregion Type files

#region Suffix file
if ($private:suffixFile | Test-Path) {
  Write-Debug "Loading suffix file $private:suffixFile"
  . $private:suffixFile
  Write-Debug "Loading prefix file $suffixFile"
  . $suffixFile
  [void]$sourceFiles.Remove([Path]::GetRelativePath($PSScriptRoot, $suffixFile))
}
#endregion Suffix file


# Get the internal TypeAccelerators class to use its static methods.
$private:typeAcceleratorsClass = [psobject].Assembly.GetType(
  'System.Management.Automation.TypeAccelerators'
)
# Ensure none of the types would clobber an existing type accelerator.
# If a type accelerator with the same name exists, throw an exception.
$existingTypeAccelerators = $typeAcceleratorsClass::Get
foreach ($type in $exportableTypes) {
  Write-Debug "Exporting $type"
  if ($type.FullName -in $existingTypeAccelerators.Keys) {
    $message = @(
      "Unable to register type accelerator '$($type.FullName)'"
      'Accelerator already exists.'
    ) -join ' - '

    throw [System.Management.Automation.ErrorRecord]::new(
      [System.InvalidOperationException]::new($message),
      'TypeAcceleratorAlreadyExists',
      [System.Management.Automation.ErrorCategory]::InvalidOperation,
      $type.FullName
    )
  }
}
# Add type accelerators for every exportable type.
foreach ($type in $exportableTypes) {
  $typeAcceleratorsClass::Add($type.FullName, $type)
}
# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
  foreach($type in $exportableTypes) {
    $typeAcceleratorsClass::Remove($type.FullName)
  }
}.GetNewClosure()
