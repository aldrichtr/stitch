function Add-XmlElement {
	[OutputType([System.Xml.XmlElement])]
	param(
		[Parameter(Mandatory=1)]
		[System.Xml.XmlElement] $Xml,
		[Parameter(Mandatory=1)]
		[string] $Name
	)
	$Xml.AppendChild($Xml.OwnerDocument.CreateElement($Name))
}
