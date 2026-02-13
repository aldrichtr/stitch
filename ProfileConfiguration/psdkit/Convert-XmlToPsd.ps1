function Convert-XmlToPsd {
	[OutputType([string])]
	param(
		[Parameter(Position=0, Mandatory=1)]
		[System.Xml.XmlNode] $Xml,
		[string] $Indent
	)
	trap {ThrowTerminatingError $_}

	if (!$Indent) {
		if (!($doc = $Xml.OwnerDocument)) {$doc = $Xml}
		if ($attr = $doc.DocumentElement.GetAttribute('Indent')) {$Indent = $attr}
	}

	$script:LineStarted = $false
	$script:Indent = Convert-Indent $Indent
	$script:Writer = New-Object System.IO.StringWriter
	try {
		if ($Xml.NodeType -ceq 'Document') {
			Write-XmlChild $Xml.DocumentElement
		}
		elseif ($Xml.Name -ceq 'Item') {
			Write-XmlChild $Xml
		}
		else {
			Write-XmlElement $Xml
		}
		$script:Writer.ToString()
	}
	finally {
		$script:Writer = $null
	}
}
