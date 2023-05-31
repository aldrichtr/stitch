
function Test-PathIsIn {
    <#
    .SYNOPSIS
        Confirm if the given path is within the other
    .DESCRIPTION
        `Test-PathIsIn` checks if the given path (-Path) is a subdirectory of the other (-Parent)
    .EXAMPLE
        Test-PathIsIn "C:\Windows" -Path "C:\Windows\System32\"

    .EXAMPLE
        "C:\Windows\System32" | Test-PathIsIn "C:\Windows"
    #>
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param(
        # The path to test (the subdirectory)
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # The path to test (the subdirectory)
        [Parameter(
            Position = 0
        )]
        [string]$Parent,

        # Compare paths using case sensitivity
        [Parameter(
        )]
        [switch]$CaseSensitive
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        try {
            Write-Debug "Resolving given Path $Path"
            $childItem = Get-Item (Resolve-Path $Path)

            Write-Debug "Resolving given Parent $Parent"
            $parentItem = Get-Item (Resolve-Path $Parent)

            if ($CaseSensitive) {
                Write-Debug "Matching case-sensitive"
                $parentPath = $parentItem.FullName
                $childPath = $childItem.FullName
            } else {
                Write-Debug "Matching"
                $parentPath = $parentItem.FullName.ToLowerInvariant()
                $childPath = $childItem.FullName.ToLowerInvariant()
            }

            Write-Verbose "Testing if '$childPath' is in '$parentPath'"

            # early test using string comparison
            #! note: will return a false positive for directories with partial match like
            #! c:\windows\system , c:\windows\system32
            Write-Debug "Does '$childPath' start with '$parentPath'"
            if (-not($childPath.StartsWith($parentPath))) {
                Write-Debug " - Yes.  Return False"
                return $false
            } else {
                $childRoot = $childItem.Root
                $parentRoot = $parentItem.Root
                Write-Debug " - Yes. Checking path roots '$childRoot' and '$parentRoot'"

                # they /should/ be equal if we made it here
                if ($parentRoot -notlike $childRoot) {
                    return $false
                }

                $childPathParts = $childPath -split [regex]::Escape([IO.Path]::DirectorySeparatorChar)
                $depth = $childPathParts.Count
                $currentPath = $childItem
                $parentFound = $false
                :depth foreach ($level in 1..($depth - 1)) {
                    $currentPath = $currentPath.Parent
                    Write-Debug "Testing if $currentPath equals $($parentItem.FullName)"
                    if ($currentPath -like $parentItem.FullName) {
                        Write-Debug " - Parent found"
                        $parentFound = $true
                        break depth
                    }
                }
                if ($parentFound) {
                    Write-Debug " - Parent found.  Return True"
                    return $true
                }
                Write-Debug " - Parent not found.  Return False"
                return $false

            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }


}
