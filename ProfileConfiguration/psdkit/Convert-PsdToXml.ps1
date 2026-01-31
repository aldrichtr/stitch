function Convert-PsdToXml {
	[OutputType([xml])]
	param(
		[Parameter(Position=0, Mandatory=1, ValueFromPipeline=1)]
		[string] $InputObject
	)
	process {
		trap {ThrowTerminatingError $_}
		New-PsdXml $InputObject
	}
}
