param(
)


$phaseAlias = Get-Alias 'phase' -ErrorAction SilentlyContinue

if ($null -eq $phaseAlias) {
    Set-Alias -Name phase -Value Add-BuildTask -Description 'Top level task associated with a development lifecycle phase'
}

Remove-Variable phaseAlias
#-------------------------------------------------------------------------------
#region phase definition

#synopsis: 1. Ensure the project is correct and all necessary information is available
phase Validate

#synopsis: 2. Initialize build state, e.g. set properties or create directories.
phase Initialize

#synopsis: 3. In projects with compiled language source, run the compiler to produce an executable
phase Compile

#synopsis: 4. Run unit tests against the source module
phase Test

#synopsis: 5. Build the source code (create/assemble a module, manifest and supporting files from source)
phase Build

#synopsis: 6. Run integration tests to ensure quality criteria are met
phase Verify

#synopsis: 7. Create a distributable package from the project
phase Package

#synopsis: 8. Install the modules from the system local PSRepo
phase Install

#synopsis: 9. Copy the final package to the remote repository
phase Deploy

#synopsis: Remove and uninstall the module from the system
phase Uninstall

#endregion phase definition
#-------------------------------------------------------------------------------
