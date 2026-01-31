
using namespace System.Collections
function Resolve-ProfileTree {
  <#
  .SYNOPSIS
    Return an array of profiles that are parent <=> child
  .DESCRIPTION
    This function reads the profile structure file present in the scopes, and creates a list of profiles to be
    imported.  The main purpose of this function is to provide other functions the list of profiles that must be
    loaded
  .EXAMPLE
    $tree = Resolve-ProfileTree 'prod'
  .NOTES
    Profiles defined at any level affect all levels.
  #>
  [CmdletBinding()]
  param(
    # Return the Configuration of a specific Profile
    [Parameter(
      Position = 0,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [string]$Name,

    # Return the list of profiles in order from child to parent instead of parent to child
    [Parameter(
    )]
    [switch]$Ascending

  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    $PROFILE_STRUCTURE_FILE = 'profiles.psd1'
    $profileStructure = [ArrayList]::new()
    $profileNames = [ArrayList]::new(@('default'))

    [void]$profileStructure.Add( @{
        Name    = 'default'
        Parent  = '-'
        Inherit = $false
      })

    $MAX_PATH_ITERATIONS = 5

    $profileTree = [ArrayList]::new()
  }
  process {
    #. Rotate through the scopes but top-down.  Add profiles only if they were
    #. already added at a scope above

    if (-not ($PSBoundParameters.ContainsKey('Name'))) {
      $Name = 'default'
    }

    # SECTION Build structure
    # NOTE: The structure we end up with is an Array of HashTables, where each
    # table has a Name, a Parent, and whether to Inherit.
    # If we made it here then we want some profile other than 'default' which is always the base
    # So find the table in the list with the matching name, and build the list, working backwards,
    # up to the root
    foreach ($scope in ('Local', 'User', 'System')) {
      $path = Resolve-ScopeRoot $scope
      Write-Debug "At scope '$scope' using path '$path'"
      $possibleProfileFile = (Join-Path $path $PROFILE_STRUCTURE_FILE)
      if ($possibleProfileFile | Test-Path) {
        Write-Debug '- There is a profiles config here'
        $scopedStructure = Import-Psd $possibleProfileFile
        if ($null -ne $scopedStructure) {
          Write-Debug '- Successfully imported the structure'
          foreach ($table in $scopedStructure) {
            #! Profiles will not be added if they don't have a 'Name' field
            if ($null -ne $table.Name) {
              Write-Debug "  - Successfully imported a profile config $($scopedStructure | ConvertTo-Json)"
              if ($table.Name -notin $profileNames) {
                Write-Debug '  - This profile is not in the structure yet'
                #! Add additional metadata here
                $table['Scope'] = $scope
                if (-not ($table.ContainsKey('Parent'))) {
                  Write-Debug "    - No Parent given, so setting to 'default'"
                  $table['Parent'] = 'default'
                }
                if (-not ($table.ContainsKey('Inherit'))) { $table['Inherit'] = $true }

                if (-not $table.Inherit) { $table.Parent = '-' }

                [void]$profileNames.Add($table.Name)
                [void]$profileStructure.Add($table)
              } # end if notin Names
            } # end if table.Name
          } # end foreach table
        } else {
          throw "There was an error Loading profile structure file $path"
        } # end if scopedStructure
      } # end if profile file
    } # end foreach scope
    # !SECTION

    # NOTE: At this point we have the profile structure, now we can make the list of
    # profiles from this one back to the root via the Parent attribute

    Write-Debug "Structure is built:`n$($profileStructure | ConvertTo-Json)`n-  Now finding profile '$Name'"
    $cName = $Name
    #! ensure we don't end up in an infinite loop
    $counter = 0
    :parent do {
      $counter++
      Write-Debug "- Now looking up '$cName'"
      if ($cName -in $profileNames) {
        $cStep = $profileStructure |
          Where-Object { $_.Name -like $cName }
        if ($null -eq $cStep) {
          Write-Warning "$cName profile was not found. Skipping"
        }
      } else {
        Write-Warning "$cName does not exist in profiles. Skipping"
      }
      [void]$profileTree.Add($cName)
      $cName = $cStep.Parent
    } until (($cName -eq '-') -or ($counter -ge $MAX_PATH_ITERATIONS))
  }
  end {
    # NOTE: - The profiles have been arranged from child to parent, but most other functions will need to
    # operate on the top-most profile, and then /layer/ the child profiles on top of them.  So reverse the order
    # unless they explicitly tell us not to
    if (-not $Ascending) { [void]$profileTree.Reverse() }

    Write-Output -InputObject $profileTree -NoEnumerate

    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
