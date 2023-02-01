#-------------------------------------------------------------------------------
#region Discovery
BeforeDiscovery {
    if (-not($Global:StitchModuleLoaded)) {
        $thisFile = (Get-Item $PSCommandPath)

        $moduleLoaderFile = (Join-Path $thisFile.Directory 'loadModule.ps1')
        if (Test-Path $moduleLoaderFile) {
            . $moduleLoaderFile
        }
    }
}
#endregion Discovery
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#region All

BeforeAll {}

AfterAll {}

#endregion All
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Each

BeforeEach {}

AfterEach {}

#endregion Each
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#region Custom Assertions

#endregion Custom Assertions
#-------------------------------------------------------------------------------
