
using namespace System.Collections
function Resolve-ProfileTree {
  <#
  .SYNOPSIS
    Return an array of profiles that are parent <=> child
  .DESCRIPTION
    This function reads the profile structure file present in the scopes, and creates a list of profiles to be
    imported.
  .NOTES
    Profiles defined at any level affect all levels.
  #>
  [CmdletBinding()]
  param(
    # Return the Configuration of a specific Profile
    [Parameter(
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [string]$Name
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    $PROFILE_STRUCTURE_FILE = 'profiles.psd1'
    $profileStructure = [ArrayList]::new()
    [void]$profileStructure.Add( @{
        Name    = 'default'
        Parent  = '-'
        Inherit = $false
      })

    $profileNames = [ArrayList]::new(@('default'))
  }
  process {
    #. Rotate through the scopes but top-down.  Add profiles only if they were
    #. already added at a scope above

    if (-not ($PSBoundParameters.ContainsKey('Name'))) {
      return 'default'
    } else {
      # SECTION Build structure
      # NOTE: The structure we end up with is an Array of HashTables, where each
      # table has a Name, a Parent, and whether to Inherit.
      # If we made it here then we want some profile other than 'default' which is always the base
      # So find the table in the list with the matching name, and build the list, working backwards,
      # up to the root
      foreach ($scope in ('Local', 'User', 'System')) {
        $path = Get-StitchConfigurationPath $scope
        if ($path | Test-Path) {
          $possibleProfileFile = (Join-Path $path $PROFILE_STRUCTURE_FILE)
          if ($possibleProfileFile | Test-Path) {
            $scopedStructure = Import-Psd $possibleProfileFile
            foreach ($table in $scopedStructure) {
              #! Profiles will not be added if they don't have a 'Name' field
              if ($null -ne $table.Name) {
                if ($table.Name -notin $profileNames) {
                  #! Add additional metadata here
                  $table['Scope'] = $scope
                  if (-not ($table.ContainsKey('Parent'))) { $table['Parent'] = 'default' }
                  if (-not ($table.ContainsKey('Inherit'))) { $table['Inherit'] } = $true

                  if (-not $table.Inherit) {
                    $table.Parent = '-'
                  }

                  [void]$profileNames.Add($table.Name)
                  [void]$profileStructure.Add($table)
                }
              }
            }
          }
        }
      }
      # !SECTION

      # NOTE: At this point we have the profile structure, now we can make the list of
      # profiles from this one back to the root via the Parent attribute

      $cName = $Name
      do {
        if ($cName -in $profileNames) {
          $cStep = $profileStructure |
            Where-Object { $_.Name -like $cName }
          if ($null -ne $cStep) {
            Write-Warning "$cName profile was not found. Skipping"
          }
        } else {
          Write-Warning "$cName does not exist in profiles. Skipping"
        }
        $cName = $cStep.Parent

      } until ($cName -eq '-')
    }

  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
