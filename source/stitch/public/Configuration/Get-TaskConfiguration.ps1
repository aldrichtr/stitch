

function Get-TaskConfiguration {
    [CmdletBinding()]
    param(
        # The task object
        [Parameter(
            Position = 1,
            ValueFromPipeline
        )]
        [psobject]$Task,

        [Parameter(
            Position = 0
        )]
        [string]$TaskConfigPath
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if (-not($PSBoundParameters.ContainsKey('TaskConfigPath'))) {
            Write-Debug "No TaskConfigPath given. Looking for BuildConfigPath"
            $possibleBuildConfigPath = $PSCmdlet.GetVariableValue('BuildConfigPath')
            if (-not ([string]::IsNullorEmpty($possibleBuildConfigPath))) {
                Write-Debug "found BuildConfigPath at $possibleBuildConfigPath"
                $BuildConfigPath = $possibleBuildConfigPath
                $TaskConfigPath = (Join-Path -Path $BuildConfigPath -ChildPath 'config' -AdditionalChildPath 'tasks')
                Remove-Variable possibleBuildConfigPath -ErrorAction SilentlyContinue
            }
        }
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if ($null -eq $TaskConfigPath) {
            throw "Could not find $($Task.Name) configuration because TaskConfigPath was not set"
        }

        if (Test-Path $TaskConfigPath) {
        Write-Debug "Looking for task config files in $TaskConfigPath"
            $taskConfigFiles = Get-ChildItem -Path $TaskConfigPath -Filter "*.config.psd1"
            Write-Debug "  - Found $($taskConfigFiles.Count) config files"
            foreach ($taskConfigFile in $taskConfigFiles) {
                if ((-not ($PSBoundParameters.ContainsKey('Task'))) -or
                ($TaskConfigFile.BaseName -like "$($Task.Name).config"))  {
                    try {
                        $config = Import-Psd -Path $taskConfigFile -Unsafe
                        $config['TaskName'] = ($TaskConfigFile.BaseName -replace '\.config$', '')
                    } catch {
                        throw "THere was an error loading $taskConfigFile `n$_"
                    }
                    $config | Write-Output
                }
            }

        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
