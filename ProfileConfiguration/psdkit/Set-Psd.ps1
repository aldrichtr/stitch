function Set-Psd {
	param(
		[Parameter(Position=0, Mandatory=1)]
		[System.Xml.XmlNode] $Xml,
		[Parameter(Position=1, Mandatory=1)]
		[AllowEmptyString()]
		[AllowNull()]
		$Value,
		[Parameter(Position=2)]
		[string] $XPath
	)
	trap {ThrowTerminatingError $_}
	if ($XPath) {
		$node = $xml.SelectSingleNode($XPath)
		if (!$node) {throw 'XPath selects nothing.'}
	}
	else {
		$node = $Xml
	}
	if ($node.NodeType -ne 'Element') {throw "Unexpected node type '$($node.NodeType)'."}

	if ($node.Name -eq 'Comment') {
		if ($Value -isnot [string]) {throw 'Comment must be a string.'}
		if ($Value.StartsWith('#')) {
			if ($Value -match '[\r\n]') {throw 'Line comment must be one line.'}
		}
		elseif ($Value.StartsWith('<#')) {
			if (!$Value.EndsWith('#>')) {throw "Block comment must end with '#>'."}
		}
		else {
			throw 'Comment must be line #... or block <#...#>.'
		}
		$node.InnerText = $Value
		return
	}

	$newXml = Convert-PsdToXml (ConvertTo-Psd $Value)

	$newNode = $newXml.DocumentElement
	if ($newNode.ChildNodes.Count -ne 1) {throw 'Not supported new value.'}
	$newNode = $node.OwnerDocument.ImportNode($newNode.FirstChild, $true)

	if ($node.Name -eq 'Item') {
		if ($node.ChildNodes.Count -ne 1) {throw 'Not supported old value.'}
		$null = $node.ReplaceChild($newNode, $node.FirstChild)
	}
	else {
		$null = $node.ParentNode.ReplaceChild($newNode, $node)
	}
}
