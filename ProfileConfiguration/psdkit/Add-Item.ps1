function Add-Item($elem, $t1, $Type) {
	$elem = Add-XmlElement $elem Item
	$elem.SetAttribute('Key', $t1.Content)
	if ($Type) {
		$elem.SetAttribute('Type', $Type)
	}

	$t1 = $script:Queue.Dequeue()
	if ($t1.Type -ne 'Operator' -or $t1.Content -ne '=') {
		ThrowUnexpectedToken $t1
	}

	$valueAdded = $false
	while($script:Queue.Count) {
		$t1 = $script:Queue.Peek()
		switch ($t1.Type) {
			GroupEnd {
				return
			}
			StatementSeparator {
				return
			}
			NewLine {
				if ($valueAdded) {
					return
				}
				$null = $script:Queue.Dequeue()
				$null = Add-XmlElement $elem NewLine
				break
			}
			Comment {
				$null = $script:Queue.Dequeue()
				$e = Add-XmlElement $elem Comment
				$e.InnerText = $t1.Content
				break
			}
			Operator {
				if ($t1.Content -eq ',') {
					$valueAdded = $false
					$null = $script:Queue.Dequeue()
					$null = Add-XmlElement $elem Comma
				}
				else {
					ThrowUnexpectedToken $t1
				}
				break
			}
			default {
				$null = $script:Queue.Dequeue()
				$valueAdded = $true
				Add-Value $elem $t1
			}
		}
	}
}
