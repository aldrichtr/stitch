
function Undo-GitCommit {
    <#
    .SYNOPSIS
        Reset the branch to before the previous commit
    .DESCRIPTION
        There are three types of reset:
        but keep all the changes in the working directory
        Without This is equivelant to `git reset HEAD~1 --mixed
    #>
    [CmdletBinding()]
    param(
        # Hard reset
        [Parameter(
            ParameterSetName = 'Hard'
        )]
        [switch]$Hard,

        # Soft reset
        [Parameter(
            ParameterSetName = 'Soft'
        )]
        [switch]$Soft



    )
    #! The default mode is mixed, it does not have a parameter
    Reset-GitHead -Revision 'HEAD~1' @PSBoundParameters
}
