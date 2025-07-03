@{
  #---------------------------------------------------------------------------
  #region Module Info

  ModuleVersion     = '0.1.0'
  Description       = 'A PowerShell build system stitching together Invoke-Build tasks'
  GUID              = 'de471cc1-be4b-48e7-a033-6a1f16d7fae8'
  HelpInfoURI       = 'https://github.com/aldrichtr/stitch/blob/main/docs/en-US/stitch-help.xml'

  #endregion Module Info
  #---------------------------------------------------------------------------

  #---------------------------------------------------------------------------
  #region Module Components

  RootModule        = 'stitch.psm1'
  # ScriptsToProcess = @()
  # TypesToProcess = @()
  # FormatsToProcess = @()
  # NestedModules = @()
  # ModuleList = ''
  # FileList = @()

  #endregion Module Components
  #---------------------------------------------------------------------------

  #---------------------------------------------------------------------------
  #region Public Interface

  CmdletsToExport   = '*'
  FunctionsToExport = '*'
  VariablesToExport = '*'
  AliasesToExport   = '*'
  # DSCResourcesToExport = @()
  # DefaultCommandPrefix = ''

  #endregion Public Interface
  #---------------------------------------------------------------------------

  #---------------------------------------------------------------------------
  #region Requirements

  #region Environment
  # ProcessorArchitecture = ''
  # DotNetFrameworkVersion = ''
  # CLRVersion = ''
  #endregion Environment

  #region PowerShell host
  # PowershellHostName = ''
  # PowershellHostVersion = ''
  # PowerShellVersion = ''
  # CompatiblePSEditions = @()
  #endregion PowerShell host

  # RequiredModules = @()
  # RequiredAssemblies = @()

  #endregion Requirements
  #---------------------------------------------------------------------------

  #---------------------------------------------------------------------------
  #region Author

  Author            = 'Timothy R. Aldrich'
  CompanyName       = 'ASI'
  Copyright         = '(c) Timothy R. Aldrich. All rights reserved.'

  #endregion Author
  #---------------------------------------------------------------------------

  PrivateData       = @{
    PSData = @{
      #---------------------------------------------------------------------------
      #region Project

      # Tags = @()
      LicenseUri = 'https://github.com/aldrichtr/stitch/LICENSE'
      ProjectUri = 'https://github.com/aldrichtr/stitch'
      IconUri                    = ''
      # PreRelease = ''
      RequireLicenseAcceptance   = $false
      ExternalModuleDependencies = @()
      ReleaseNotes               = ''

      #endregion Project
      #---------------------------------------------------------------------------

    } # end PSData
  } # end PrivateData
} # end hashtable
