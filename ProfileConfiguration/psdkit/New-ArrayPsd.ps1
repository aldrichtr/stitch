function New-ArrayPsd($node) {
	$r = [System.Collections.Generic.List[object]]@()
	foreach($node in $node.ChildNodes) {switch($node.Name) {
		NewLine {
			break
		}
		String {
			$r.Add($node.InnerText)
			break
		}
		Number {
			$r.Add((New-NumberPsd $node.InnerText))
			break
		}
		Variable {
			$r.Add((New-VariablePsd $node.InnerText))
			break
		}
		Table {
			$r.Add((New-TablePsd $node))
			break
		}
		Cast {
			$r.Add((New-CastPsd $node))
			break
		}
		Comma {
			break
		}
		Comment {
			break
		}
		Semicolon {
			break
		}
		Block {
			$r.Add([scriptblock]::Create($node.InnerText))
			break
		}
		default {
			throw "Array contains not supported node '$_'."
		}
	}}
	, $r
}
