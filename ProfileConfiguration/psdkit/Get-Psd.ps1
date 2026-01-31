function Get-Psd {
	param(
		[Parameter(Position=0, Mandatory=1)]
		[System.Xml.XmlNode] $Xml,
		[Parameter(Position=1)]
		[string] $XPath
	)
	trap {ThrowTerminatingError $_}
	if ($XPath) {
		$node = $xml.SelectSingleNode($XPath)
		if (!$node) {throw "XPath selects nothing: '$XPath'."}
	}
	else {
		$node = $Xml
	}
	switch($node.Name) {
		Item {
			return New-ItemPsd $node
		}
		String {
			return $node.InnerText
		}
		Number {
			return New-NumberPsd $node.InnerText
		}
		Variable {
			return New-VariablePsd $node.InnerText
		}
		Comment {
			return $node.InnerText
		}
		Array {
			return New-ArrayPsd $node
		}
		Table {
			return New-TablePsd $node
		}
		Cast {
			return New-CastPsd $node
		}
		Data {
			return New-ItemPsd $node
		}
		Block {
			return [scriptblock]::Create($node.InnerText)
		}
		'#document' {
			return New-ItemPsd $node
		}
		default {
			throw "Not supported node '$_'."
		}
	}
}
