function New-TablePsd($node) {
	$r = [System.Collections.Specialized.OrderedDictionary]([System.StringComparer]::OrdinalIgnoreCase)
	foreach($node in $node.ChildNodes) {switch($node.Name) {
		NewLine {
			break
		}
		Item {
			if ($node.GetAttribute('Type') -eq 'Number') {
				$key = New-NumberPsd $node.Key
			}
			else {
				$key = $node.Key
			}
			$r.Add($key, (New-ItemPsd $node))
			break
		}
		Comment {
			break
		}
		Semicolon {
			break
		}
		default {
			throw "Table has not supported node '$($node.Name)'."
		}
	}}
	$r
}
