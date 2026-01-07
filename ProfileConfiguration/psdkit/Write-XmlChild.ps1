function Write-XmlChild($elem, $Depth=0) {
	foreach($e in $elem.ChildNodes) {
		Write-XmlElement $e $Depth
	}
}
