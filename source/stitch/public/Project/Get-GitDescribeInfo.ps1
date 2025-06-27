
function Get-GitDescribeInfo {
    <#
    .SYNOPSIS
        Return the version information found in `git describe`
    .DESCRIPTION
        `git describe` will print out the version information in the form of:
        <tag>-<commits since>-<short sha>
    #>
    [CmdletBinding()]
    param(
        # Only use annotated tags (--tags is used by default)
        [Parameter(
        )]
        [switch]$AnnotatedOnly
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $describePattern = (@(
                '^v?(?<majr>\d+)\.',
                '(?<minr>\d+)\.',
                '(?<ptch>\d+)',
                '(?<rmdr>.*)$'
            ) -join '')

        $versionInfo = @{
            PSTypeName                = 'Stitch.VersionInfo'
            Full                      = ''
            Major                     = 0
            Minor                     = 0
            Patch                     = 0
            CommitsSinceVersionSource = 0
            ShortSha                  = ''
            PreReleaseTag             = ''
            MajorMinorPatch           = ''
            SemVer                    = ''
        }
    }
    process {
        $gitCommand = (Get-Command 'git.exe' -ErrorAction SilentlyContinue)

        if ($null -ne $gitCommand) {
            $arguments = [System.Collections.ArrayList]@('describe')

            if (-not($AnnotatedOnly)) { [void]$arguments.Add('--tags') }

            [void]$arguments.Add('--long')
            Write-Debug "calling git with arguments $($arguments -join ' ')"
            $result = & $gitCommand $arguments

            if ($result.Length -gt 0) {
                $versionInfo.Full = $result
                if ($result -match $describePattern) {
                    $versionInfo.Major = ($Matches.majr ?? 0)
                    $versionInfo.Minor = ($Matches.minr ?? 0)
                    $versionInfo.Patch = ($Matches.ptch ?? 0)

                    $versionInfo.MajorMinorPatch = ('{0}.{1}.{2}' -f $Matches.majr, $Matches.minr, $Matches.ptch)

                    $parts = [System.Collections.ArrayList]@($Matches.rmdr.Split('-'))

                    switch ($parts.Count) {
                        0 { Write-Debug "Did not find any parts in $($Matches.rmdr)" }
                        1 {
                            $versionInfo.ShortSha = $parts[0]
                            continue
                        }
                        2 {
                            $versionInfo.CommitsSinceVersionSource  = $parts[0]
                            $versionInfo.ShortSha = $parts[1]
                            continue
                        }
                        default {
                            $versionInfo.ShortSha = $parts[-1]
                            [void]$parts.Remove($parts[-1])
                            $versionInfo.CommitsSinceVersionSource = $parts[-1]
                            [void]$parts.Remove($parts[-1])
                            $versionInfo.PreReleaseTag   = ($parts -join '-')
                        }
                    }

                    $versionInfo.SemVer = ( @(
                        $versionInfo.MajorMinorPatch,
                        $versionInfo.PreReleaseTag) -join '')
                    [PSCustomObject]$versionInfo | Write-Output
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
