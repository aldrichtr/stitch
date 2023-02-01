BeforeDiscovery {
    if (-not($Global:StitchModuleLoaded)) {
        $thisFile = (Get-Item $PSCommandPath)

        $moduleLoaderFile = (Join-Path $thisFile.Directory 'loadModule.ps1')
        if (Test-Path $moduleLoaderFile) {
            . $moduleLoaderFile
        }
    }
}

Describe 'Testing the public function Test-ProjectRoot' -Tag @('unit', 'public') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Test-ProjectRoot'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }
    Context 'When at least two of the default directories are present' {
        BeforeAll {
            $tDefaults = @{
                Source   = '.\source'
                Staging  = '.\stage'
                Tests    = '.\tests'
                Artifact = '.\out'
                Docs     = '.\docs'
            }
            $tProjectName = 'ProjectA'
            $tProjectPath = (New-Item -Path "TestDrive:\$tProjectName" -ItemType Directory)

            function createDefaultPath {
                param(
                    [Parameter()]
                    [string]$Type
                )
                New-Item -Path (Join-Path $tProjectPath $tDefaults[$Type]) -ItemType Directory
            }
        }
        Context 'When <Description> are present' -ForEach @(
            @{ Description = 'Source'  ; Paths = 'Source'  ; ReturnValue = $false }
            @{ Description = 'Source and Staging'  ; Paths = 'Source', 'Staging'  ; ReturnValue = $true }
            @{ Description = 'Source and Tests'    ; Paths = 'Source', 'Tests'    ; ReturnValue = $true }
            @{ Description = 'Source and Artifact' ; Paths = 'Source', 'Artifact' ; ReturnValue = $true }
            @{ Description = 'Source and Docs'     ; Paths = 'Source', 'Docs'     ; ReturnValue = $true }
        ) {

            BeforeAll {
                foreach ($path in $Paths) {
                    createDefaultPath -Type $path
                }
            }

            It 'Should be <ReturnValue>' {
                $tProjectPath | Test-ProjectRoot | Should -Be $ReturnValue
            }
        }
    }
}
