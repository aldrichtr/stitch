
using namespace System.Diagnostics.CodeAnalysis


function Export-ReleaseNotes {
    [SuppressMessage('PSUseSingularNouns', '', Justification = 'ReleaseNotes is a single document' )]
    [CmdletBinding()]
    param(
        # Specifies a path to the Changelog.md file
        [Parameter(
            Position = 2,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path = 'CHANGELOG.md',

        # The path to the destination file.  Outputs to pipeline if not specified
        [Parameter(
            Position = 0
        )]
        [string]$Destination,

        # The release version to create a release from
        [Parameter(
        )]
        [string]$Release
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $changelogData = $null
        function outputItem {
            param(
                [Parameter(
                    Position = 1,
                    ValueFromPipeline
                )]
                [string]$Item,

                [Parameter(
                    Position = 0
                )]
                [bool]$toFile
            )
            if ($toFile) {
                $Destination | Add-Content $Item
            } else {
                $Item | Write-Output
            }
        }
    }
    process {
        $writeToFile = $PSBoundParameters.ContainsKey('Destination')

        if (-not ([string]::IsNullorEmpty($Path))) {
            if (Test-Path $Path) {
                Write-Debug "Converting Changelog : $Path"
                $dpref = $DebugPreference
                $DebugPreference = 'SilentlyContinue'
                $changelogData = ($Path | ConvertFrom-Changelog)
                $DebugPreference = $dpref
                if ($null -ne $changelogData) {
                    Write-Debug "There are $($changelogData.Releases.Count) release sections"
                    :section foreach ($section in $changelogData.Releases ) {
                        Write-Debug "$($section.Type) Section: Version = $($section.Version) Timestamp = $($section.Timestamp)"
                        if ($section.Type -like 'Unreleased') {
                            continue section
                        }
                        if (-not ([string]::IsNullorEmpty($Release))) {
                            if ( [semver]::new($section.Version) -gt [semver]::new($Release)) {
                                continue section
                            }
                        }
                        #! we can use our Format to assemble the Timestamp, version, etc
                        #! the other items should already be in the format we want
                        $section | Format-ChangelogRelease | outputItem $writeToFile
                        foreach ($group in $section.Groups) {
                            #! no need to reformat it
                            $group | Format-ChangelogGroup | outputItem $writeToFile
                            foreach ($entry in $group.Entries) {
                                $entry | Format-ChangelogEntry | outputItem $writeToFile
                            }
                        }
                    }
                }
            }
        } else {
            throw "$Path is not a valid Path"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
