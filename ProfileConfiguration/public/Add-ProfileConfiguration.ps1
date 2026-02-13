function Add-ProfileConfiguration {
    <#
    .SYNOPSIS
        Add a new item to the configuration
    .DESCRIPTION
        Add a new item to the configuration hierarchy.
    #>
    [CmdletBinding()]
    param(
        # The value to Add
        [Parameter(
        )]
        [Object]$Value,

        # The key to add the configuration to
        [Parameter(
        )]
        [string]$Key
    )
    begin {
        $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
    }
    process {
        #switch ($Value.GetType().IsArray()) {

        #}
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
    }
}
