<#
Use this file to manage the phases and tasks.
#>

#-------------------------------------------------------------------------------
#region Lifecycle phases for default
'Validate'   | before 'Initialize'
'Initialize' | before 'Compile'
'Compile'    | before 'Test'
'Test'       | before 'Build'
'Build'      | before 'Verify'
'Verify'     | before 'Package'
'Package'    | before 'Install'
#endregion Lifecycle phases for default
#-------------------------------------------------------------------------------

Add-BuildTask . 'Build'

#-------------------------------------------------------------------------------
#region Validate

'Validate' | jobs @(
    'confirm.project.directory',
    'confirm.backup.directory',
    'confirm.logging.directory',
    'confirm.module.directory')

#endregion Validate
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Initialize

'install.psdepend' | before 'install.requirement'

'Initialize' | jobs @(
    'install.psdepend',
    'install.requirement',
    'set.psmodulepath'
)
#endregion Initialize
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Compile


#endregion Compile
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Test


$unitTestOptions = @{
    Name              = 'unit.tests'
    ConfigurationFile = "$BuildConfigPath\pester\UnitTests.config.psd1"
    Type              = 'Unit'
}

# synopsis: Run the tests defined in the 'Unittests' config file
pester @unitTestOptions

Remove-Variable unitTestOptions

'Test' | jobs {
    logDebug 'Loading TestHelpers module'
    Import-Module (Join-Path $Tests 'TestHelpers.psm1') -Force
}, 'unit.tests'

#endregion Test
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Build

task 'write.module' @(
    'write.module.file',
    'write.module.file.prefix',
    'write.module.file.suffix',
    'format.module.file'
)

task 'write.manifest' @(
    'write.manifest.file',
    'add.exported.functions',
    'add.exported.aliases',
    'add.required.modules',
    'add.psformat.files',
    'format.manifest.file.array',
    'format.manifest.file'
)

'Build' | jobs @(
    'write.module.modulebuilder'
)

#endregion Build
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Verify

# synopsis: Run the tests defined in the 'IntegrationTests' config file
pester integration.tests -ConfigurationFile "$BuildConfigPath\pester\IntegrationTests.config.psd1" -Type 'Integration'

'Verify' | jobs {
    logDebug 'Loading TestHelpers module'
    Import-Module (Join-Path $Tests 'TestHelpers.psm1') -Force
}, 'integration.tests'

#endregion Verify
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Package

'register.project.psrepo' | before 'compress.nuget.package'
'unregister.project.psrepo' | after 'compress.nuget.package'

'Package' | jobs 'compress.nuget.package'

#endregion Package
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Install

'Install' | jobs 'install.module.currentuser'

#endregion Install
#-------------------------------------------------------------------------------
