@{
    RootModule        = 'RootModule.psm1'
    ModuleVersion     = '0.0.1'
    GUID              = '590aa122-7b0b-4768-a158-cf224a95df8c'
    Author            = 'Timothy Aldrich'
    CompanyName       = 'aldrichtr'
    Copyright         = '(c) Timothy Aldrich. All rights reserved.'
    Description       = 'Test module root'
    FunctionsToExport = '*'
    CmdletsToExport   = '*'
    VariablesToExport = '*'
    AliasesToExport   = '*'
    NestedModules = @(
        @{
            ModuleName = 'Module1'
            ModuleVersion = '0.0.1'
        }
        @{
            ModuleName = 'Module2'
            ModuleVersion = '0.0.1'
        }
    )
    PrivateData       = @{
        PSData = @{
            ProjectUri   = 'https://github.com/fakeid/RootModule'
            Tags         = 'utility'
            LicenseUri   = 'https://github.com/fakeid/RootModule/blob/main/LICENSE.md'
            ReleaseNotes = ''
        }
    }
}
