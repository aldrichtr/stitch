
function Checkpoint-String {
    <#
    .SYNOPSIS
        Hash the given string using the MD5 algorithm
    #>
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        # The string to hash
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$InputObject
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
        $utf8 = new-object -TypeName System.Text.UTF8Encoding
    }
    process {
        $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($InputObject)))
        $hash -replace '-', ''
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
