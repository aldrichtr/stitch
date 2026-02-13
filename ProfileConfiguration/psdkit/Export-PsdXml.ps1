function Export-PsdXml {
	param(
		[Parameter(Position=0, Mandatory=1)]
		[string] $Path,
		[Parameter(Position=1, Mandatory=1)]
		[System.Xml.XmlNode] $Xml,
		[string] $Indent
	)
	trap {ThrowTerminatingError $_}
	$Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
	[System.IO.File]::WriteAllText($Path, (Convert-XmlToPsd $Xml -Indent $Indent), ([System.Text.Encoding]::UTF8))
}
