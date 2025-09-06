function Add-Array($elem) {
	while($script:Queue.Count) {
		$t1 = $script:Queue.Dequeue()
		switch($t1.Type) {
			GroupEnd {
				return
			}
			NewLine {
				$null = Add-XmlElement $elem NewLine
				break
			}
			Comment {
				$e = Add-XmlElement $elem Comment
				$e.InnerText = $t1.Content
				break
			}
			StatementSeparator {
				$null = Add-XmlElement $elem Semicolon
				break
			}
			Operator {
				if ($t1.Content -eq ',') {
					$null = Add-XmlElement $elem Comma
				}
				else {
					ThrowUnexpectedToken $t1
				}
				break
			}
			default {
				Add-Value $elem $t1
			}
		}
	}
}
