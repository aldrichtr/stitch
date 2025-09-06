function New-PsdXml($Script) {
	$err = $null
	$tokens = [System.Management.Automation.PSParser]::Tokenize($script, [ref]$err)
	if ($err) {
		$err = $err[0]
		$t1 = $err.Token
		throw 'Parser error at {0}:{1} : {2}' -f $t1.StartLine, $t1.StartColumn, $err.Message
	}

	$indent = ''
	$lastLine = 0
	foreach($t1 in $tokens) {
		if ($t1.StartLine -eq $lastLine -or $t1.Type -eq 'NewLine' -or $t1.Type -eq 'Comment') {continue}
		if ($t1.StartColumn -eq 2) {$indent = '1'; break}
		if ($t1.StartColumn -eq 3) {$indent = '2'; break}
		if ($t1.StartColumn -gt 1) {break}
		$lastLine = $t1.StartLine
	}

	$xml = [xml]'<Data/>'
	if ($indent) {
		$xml.DocumentElement.SetAttribute('Indent', $indent)
	}

	$script:Queue = [System.Collections.Queue]$tokens
	$script:Script = $Script
	try {
		Add-Data $xml.DocumentElement
		$xml
	}
	finally {
		$script:Queue = $null
		$script:Script = $null
	}
}
