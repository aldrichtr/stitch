function New-NumberPsd($Text) {
	$r = $null
	if ([int]::TryParse($Text, [ref]$r)) {return $r}
	if ([long]::TryParse($Text, [ref]$r)) {return $r}
	if ([double]::TryParse($Text, [ref]$r)) {return $r}
	if ($Text.StartsWith('0x') -or $Text.StartsWith('0X')) {
		if ([int]::TryParse($Text.Substring(2), 'AllowHexSpecifier', $null, [ref]$r)) {return $r}
		if ([long]::TryParse($Text.Substring(2), 'AllowHexSpecifier', $null, [ref]$r)) {return $r}
	}
	throw "Not supported number '$Text'."
}
