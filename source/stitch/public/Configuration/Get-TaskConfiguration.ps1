

function Get-TaskConfiguration {
    <#
    .SYNOPSIS
        Get the configuration file for the given task if it exists.  First looks in the local user's stitch
        directory, and then the local build configuration directory
    .DESCRIPTION
        Look for the given task's configuration in `<buildconfig>/config/tasks`
    #>
    [CmdletBinding()]
    param(
        # The task object
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Name,

        [Parameter(
            Position = 0
        )]
        [string]$TaskConfigPath
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $taskConfigOptions = @{
            Filter  = '*.config.psd1'
            Recurse = $true
        }
        $taskConfigPathOptions = @{
            ChildPath           = 'config'
            AdditionalChildPath = 'tasks'
        }
        #! Because we are looking in both the user's stitch directory and the current
        #! project's stitch directory, create an empty array to hold all the files
        $taskConfigFiles = [System.Collections.ArrayList]::new()
    }
    process {
        #-------------------------------------------------------------------------------
        #region User stitch directory
        $userStitchDirectory = Find-LocalUserStitchDirectory

        if ($null -ne $userStitchDirectory) {
            $possibleUserTaskConfigDirectory = (Join-Path -Path $userStitchDirectory @taskConfigPathOptions)
            if (Test-Path $possibleUserTaskConfigDirectory) {
                Write-Debug "User task configuration directory found at $possibleUserTaskConfigDirectory"
                $userTaskConfigDirectory = $possibleUserTaskConfigDirectory
                Get-ChildItem -Path $userTaskConfigDirectory @taskConfigOptions | Merge-FileCollection ([ref]$taskConfigFiles)
            }
            Remove-Variable possibleUserTaskConfigDirectory -ErrorAction SilentlyContinue
        } else {
            Write-Verbose "No stitch directory found for in user's home"
        }
        #endregion User stitch directory
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Find path
        if (-not($PSBoundParameters.ContainsKey('TaskConfigPath'))) {
            Write-Debug 'No TaskConfigPath given. Looking for BuildConfigPath'
            $possibleBuildConfigPath = Find-BuildConfigurationDirectory
            if (-not ([string]::IsNullorEmpty($possibleBuildConfigPath))) {
                Write-Debug "found BuildConfigPath at $possibleBuildConfigPath"
                $BuildConfigPath = $possibleBuildConfigPath
                $TaskConfigPath = (Join-Path -Path $BuildConfigPath @taskConfigPathOptions)
                Remove-Variable possibleBuildConfigPath -ErrorAction SilentlyContinue

            }
        }
        #endregion Find path
        #-------------------------------------------------------------------------------


        if (Test-Path $TaskConfigPath) {
            Write-Debug "Looking for task config files in $TaskConfigPath"

            Get-ChildItem -Path $TaskConfigPath @taskConfigOptions | Merge-FileCollection ([ref]$taskConfigFiles)
            Write-Debug "  - Found $($taskConfigFiles.Count) config files"
        }

        if ($taskConfigFiles.Count -gt 0) {
            foreach ($taskConfigFile in $taskConfigFiles) {
                if ((-not ($PSBoundParameters.ContainsKey('Name'))) -or
                    ($TaskConfigFile.BaseName -like "$Name.config")) {
                    try {
                        #TODO: Use the Convert-ConfigurationFile to support any kind of config file, not just psd
                        $config = Import-Psd -Path $taskConfigFile -Unsafe
                        if ($null -eq $config) { $config = @{} }
                            $config['TaskName'] = ($TaskConfigFile.BaseName -replace '\.config$', '')
                            $config['ConfigPath'] = $TaskConfigFile.FullName
                    } catch {
                        $PSCmdlet.ThrowTerminatingError($_)
                    }
                    #TODO: I'm not sure we should return the config object here, unless we change the name to Import
                    $config | Write-Output
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
