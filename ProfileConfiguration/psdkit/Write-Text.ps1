function Write-Text($Text, [switch]$NoSpace) {
	if ($script:LineStarted) {
		if (!$NoSpace) {
			$script:Writer.Write(' ')
		}
	}
	else {
		$script:LineStarted = $true
		$script:Writer.Write($script:Indent * $Depth)
	}
	$script:Writer.Write($Text)
}
