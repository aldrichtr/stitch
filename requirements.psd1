@{
    PSDependOptions = @{
        Target = 'CurrentUser'
    }
    GitHubActions = @{
        Tags = @(
            'ci',
            'stitch',
            'publish'
        )
        Version = '1.1.0.2'
    }
    InvokeBuild = @{
        Tags = @(
            'ci',
            'stitch',
            'publish'
        )
        Version = '5.10.3'
    }

    Configuration = @{
        Tags = @(
            'ci',
            'stitch',
            'publish'
        )
        Version = '1.5.1'
    }

    BurntToast = @{
        Tags = @(
            'ci',
            'stitch',
            'publish'
        )
        Version = '0.8.5'
    }

    Metadata = @{
        Tags = @(
            'ci',
            'stitch',
            'publish'
        )
        Version = '1.5.7'
    }
    'Microsoft.PowerShell.SecretManagement' = @{
        Tags = @(
            'ci'
        )
        Version = '1.1.2'
    }
    'Microsoft.PowerShell.SecretStore' = @{
        Tags = @(
            'ci'
        )
        Version = '1.0.6'
    }
    Pester = @{
        Tags = @(
            'Testing'
            'ci'
        )
        Version = '5.4.0'
    }
    PowerGit = @{
        Tags = @(
            'ci',
            'stitch',
            'publish'
        )
        Version = '0.9.0'
    }
    PSDKit = @{
        Tags = @(
            'ci',
            'stitch',
            'publish'
        )
        Version = '0.6.2'
    }
    PSGitHub = @{
        Tags = @(
            'ci',
            'stitch',
            'publish'
        )
        Version = '0.15.240'
    }
}
