function Add-Table($elem) {
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
			Member {
				Add-Item $elem $t1
				break
			}
			String {
				Add-Item $elem $t1 -Type String
				break
			}
			Number {
				Add-Item $elem $t1 -Type Number
				break
			}
			default {
				ThrowUnexpectedToken $t1
			}
		}
	}
}
