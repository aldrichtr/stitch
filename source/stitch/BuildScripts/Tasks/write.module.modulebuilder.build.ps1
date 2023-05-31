
param(
    [Parameter()]
    [switch]$CopyEmptySourceDirs = (
        Get-BuildProperty CopyEmptySourceDirs $false
    ),

    [Parameter()][string]$ModuleFilePrefix = (
        Get-BuildProperty ModuleFilePrefix 'prefix.ps1'
    ),

    [Parameter()][string]$ModuleFileSuffix = (
        Get-BuildProperty ModuleFileSuffix 'suffix.ps1'
    )
)
<#
.SYNOPSIS
   Create module (.psm1) file, manifest and copied files for each module in source (see Build-Module help)
.DESCRIPTION
   Build.module creates a directory in `$Staging` with all of the files for the module:
   - Module file (.psm1) with all of the code from the source files copied into it
     - if $ModuleFilePrefix exists in the source directory, it's contents are placed at the top of the .psm1
     - if $ModuleFileSuffix exists in the source directory, it's contents are placed at the bottom of the .psm1
   - Module manifest (.psd1) based on the manifest in `$Source` with all of the functions in the 'Public' folder
     listed in 'ExportedFunctions'
#>
task write.module.modulebuilder {
     $BuildInfo | Foreach-Module {
        $config = $_
        $name = $config.Name
        if (-not([string]::IsNullOrEmpty($config.ModuleFile))) {
            logInfo "Calling ModuleBuilder\Build-Module for $name"
            $options = @{
                SourcePath                 = (Join-Path $config.Source $config.ManifestFile)
                SourceDirectories          = $config.SourceDirectories
                UnVersionedOutputDirectory = $true
                OutputDirectory            = [System.IO.Path]::GetRelativePath($config.Source, $config.Staging)
                PassThru                   = $true
            }
            $excludeFromCopy = @( $config.Manifest, $config.Module )
            if (Test-Path (Join-Path $config.Source $ModuleFilePrefix)) {
                $options['Prefix'] = $ModuleFilePrefix
                $excludeFromCopy += $ModuleFilePrefix

            }
            if (Test-Path (Join-Path $config.Source $ModuleFileSuffix)) {
                $options['Suffix'] = $ModuleFileSuffix
                $excludeFromCopy += $ModuleFileSuffix
            }
            $options['CopyPaths'] = @()
            foreach ($dir in ((Get-ChildItem $config.Source -Directory -Exclude $config.SourceDirectories))) {
                $rel_path = [System.IO.Path]::GetRelativePath($config.Source, $dir)

                # Only copy empty directories if specified in the build
                if (((Get-ChildItem $dir -Recurse -File).Count -gt 0) -or
                    ($CopyEmptySourceDirs)) {
                    logDebug "  Adding $($dir.BaseName) to CopyPaths"
                    $options.CopyPaths += $rel_path
                }
            }

            foreach ($file in ((Get-ChildItem $config.Source -File))) {
                if ($excludeFromCopy -notcontains $file.Name) {
                    $options.CopyPaths += [System.IO.Path]::GetRelativePath($config.Source, $file)
                }
            }

            try {
                $buildResult = Build-Module @options
            } catch {
                $message =  "There was an error calling Build-Module for $name`n$_"
                throw $message
                logError $message
                logError "Build Options:`n$($options | ConvertTo-Psd)"
            }
            if ($buildResult) {
                logInfo ((
                        "  - Build-Module Results for $($buildResult.Name) v$($buildResult.Version)",
                        "    - Manifest : $(Resolve-Path $buildResult.Path -Relative)",
                        "    - Description: $($buildResult.Description)",
                        "    - Root module: $($buildResult.RootModule)"
                    ) -join "`n")
            }
        }
    }
}
