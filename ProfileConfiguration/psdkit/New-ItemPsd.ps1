function New-ItemPsd($node) {
	foreach($node in $node.ChildNodes) {switch($node.Name) {
		Comma {break}
		NewLine {break}
		Comment {break}
		default {Get-Psd $node}
	}}
}
