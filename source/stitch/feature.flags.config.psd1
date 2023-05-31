@{
    phaseConfigFile = @{
        Enabled     = $true
        Description = 'Allow the configuration of phases (jobs, input, output, etc.) from a structured text file (psd1, yaml, json)'
    }
    buildOutputHook = @{
        Enabled     = $true
        Description = 'Allow custom scriptblocks to be called in Invoke-Build output functions (Enter-Build, Set-BuildHeader, etc.)'
    }
}
