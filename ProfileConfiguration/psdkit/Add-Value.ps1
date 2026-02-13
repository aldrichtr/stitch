function Add-Value($elem, $t1) {
	switch($t1.Type) {
		String {
			$e = Add-XmlElement $elem String
			$e.InnerText = $t1.Content
			if ($script:Script[$t1.Start] -eq '@' -and $script:Script[$t1.Start + 1] -eq "'") {
				$e.SetAttribute('Type', 1)
			}
			break
		}
		Number {
			$e = Add-XmlElement $elem Number
			$e.InnerText = $t1.Content
			break
		}
		Variable {
			$e = Add-XmlElement $elem Variable
			$e.InnerText = $t1.Content
			break
		}
		GroupStart {
			switch($t1.Content) {
				'@{' {
					$e = Add-XmlElement $elem Table
					Add-Table $e
					break
				}
				'@(' {
					$e = Add-XmlElement $elem Array
					Add-Array $e
					break
				}
				'{' {
					$e = Add-XmlElement $elem Block
					$t2 = Find-BlockEnd
					$e.InnerText = $script.Substring($t1.Start + 1, $t2.Start - $t1.Start - 1)
					break
				}
				default {
					ThrowUnexpectedToken $t1
				}
			}
			break
		}
		Type {
			$e = Add-XmlElement $elem Cast
			$v = $t1.Content
			#! v2 has no []
			$e.SetAttribute('Type', $(if ($v[0] -eq '[') {$v} else {"[$v]"}))
			$t2 = $script:Queue.Dequeue()
			Add-Value $e $t2
			break
		}
		default {
			ThrowUnexpectedToken $t1
		}
	}
}
