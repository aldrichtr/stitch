function Get-GitHubDefaultBranch {
    <#
    .SYNOPSIS
        Returns the default branch of the given github repository
    #>
    [CmdletBinding()]
    param(
        # The repository to find the default brach in
        [Parameter(
        )]
        [string]$RepositoryName
    )

    if ($PSBoundParameters.Key -notcontains 'RepositoryName') {
        $RepositoryName = Get-GitRepository | Select-Object -ExpandProperty RepositoryName
    }

    Get-GitHubRepository -RepositoryName $RepositoryName | Select-Object -ExpandProperty DefaultBranch
}
