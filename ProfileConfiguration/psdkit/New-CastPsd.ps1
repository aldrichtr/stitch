function New-CastPsd($node) {
	$typeName = $node.Type.TrimEnd(']').TrimStart('[')
	$type = [System.Management.Automation.LanguagePrimitives]::ConvertTo($typeName, [type])
	if ([type]::GetTypeCode($type) -eq 'Object') {throw "Cast to not supported type '$typeName'."}
	[System.Management.Automation.LanguagePrimitives]::ConvertTo($node.InnerText, $type)
}
