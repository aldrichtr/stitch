function Import-PsdXml {
	[OutputType([xml])]
	param(
		[Parameter(Mandatory=1)]
		[string] $Path
	)
	trap {ThrowTerminatingError $_}
	$script = [System.IO.File]::ReadAllText($PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path))
	New-PsdXml $script
}
