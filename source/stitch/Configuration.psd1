@{
  Configuration = @{
    # Regular users will not have access here
    Directory = 'config'
    Scope     = [ordered]@{
      System = '__MODULE_PATH__'
      # A User can collect all their stitch configs, etc in one folder
      User   = "$env:APPDATA\stitch"
      # Any project can add or overwrite the other two
      Local  = '.stitch'
    }
    FileTypes = @(
      '*.psd1',
      '*.json', '*.jsonc',
      '*.yaml', '*.yml',
      '*.toml')
  }

  Tasks         = @{
    Directory = 'tasks'
    Functions = @{
      Directory = 'functions'
    }
  }

  Profiles      = @{
    File      = 'profiles.psd1'
    Directory = 'profiles'
  }

  Modules       = @{
    Directory = 'modules'
  }

}
