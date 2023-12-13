param(
)


$phaseAlias = Get-Alias 'phase' -ErrorAction SilentlyContinue

if ($null -eq $phaseAlias) {
    Set-Alias -Name phase -Value Add-BuildTask -Description 'Top level task associated with a development lifecycle phase'
}

Remove-Variable phaseAlias
#-------------------------------------------------------------------------------
#region phase definition

#synopsis: configure the project is correct and all necessary information is available
phase Validate

#synopsis:	initialize build state, e.g. set properties or create directories.
phase Initialize

#synopsis: In projects with compiled language source, run the compiler to produce an executable
phase Compile

#synopsis: Build the source code (create/assemble a module, manifest and supporting files from source)
phase Build

#synopsis: Run unit tests against the source module
phase Test

#synopsis: Run any checks on results of integration tests to ensure quality criteria are met
phase Verify

#synopsis: Create a distributable package from the project
phase Package

#synopsis: Copy the final package to the remote repository
phase Deploy

#synopsis: Install the modules from the system local PSRepo
phase Install

#synopsis: Remove and uninstall the module from the system
phase Uninstall

#endregion phase definition
#-------------------------------------------------------------------------------
