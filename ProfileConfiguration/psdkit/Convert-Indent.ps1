function Convert-Indent($Indent) {
	switch($Indent) {
		'' {return '    '}
		'1' {return "`t"}
		'2' {return '  '}
		'4' {return '    '}
		'0' {return ''}
	}
	$Indent
}
