<#
Use this file to manage the phases and tasks.
#>

'Validate' | jobs 'confirm.project.directory',
        'confirm.backup.directory',
        'confirm.logging.directory',
        'confirm.module.directory'

'Clean' | jobs 'clean.staging', 'clean.artifacts', 'Validate'

# synopsis: Run the tests defined in the 'Unittests' config file
pester unit.tests -ConfigurationFile "$BuildConfigPath\pester\UnitTests.config.psd1"

'Test' | jobs {
    logDebug "Loading TestHelpers module"
    Import-Module (Join-Path $Tests 'TestHelpers.psm1') -Force
}, 'unit.tests'

Add-BuildTask 'write.module' @(
    'write.module.file',
    'write.module.file.prefix',
    'write.module.file.suffix',
    'format.module.file'
)

Add-BuildTask 'write.manifest' @(
    'write.manifest.file',
    'add.exported.functions',
    'add.import.functions',
    'add.exported.aliases',
    'add.required.modules',
    'add.psformat.files',
    'format.manifest.file.array',
    'format.manifest.file'
)

'Build' | jobs @(
    'Clean',
    'Test',
    'write.module',
    'write.manifest',
    'copy.additional.item'
)

# synopsis: Run the tests defined in the 'IntegrationTests' config file
pester integration.tests -ConfigurationFile "$BuildConfigPath\pester\IntegrationTests.config.psd1" -Type 'Integration'

'Verify' | jobs {
    logDebug "Loading TestHelpers module"
    Import-Module (Join-Path $Tests 'TestHelpers.psm1') -Force
}, 'integration.tests'


'Package' | jobs 'Build', <# 'Verify' ,#> 'compress.nuget.package'

'register.project.psrepo' | before 'compress.nuget.package'
'unregister.project.psrepo' | after 'compress.nuget.package'

'Install' | jobs 'Package', 'install.module.currentuser'

Add-BuildTask . Build
