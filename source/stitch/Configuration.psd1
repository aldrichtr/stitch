@{
  # SECTION Locations
  Configuration = @{
    <#
     # Regular users will not have access here
     #? It might make sense to set it to the install directory of the stitch module
     #>
    System = $__Metadata__PSScriptRoot__
    User = "$env:APPDATA\stitch"       <# A User can collect all their stitch configs, etc in one folder #>
    Local = '.stitch'                  <# Any project can add or overwrite the other two #>
  }
  # !SECTION

  # SECTION Profiles
  Profiles = @{
    File = 'profiles.psd1'
    Directory = 'profiles'
  }
  # !SECTION

  # SECTION Config files
  FileTypes = @( '*.psd1', '*.json', '*.jsonc', '*.yaml', '*.yml', '*.toml')
  # !SECTION
}
