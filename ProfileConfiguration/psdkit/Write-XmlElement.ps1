function Write-XmlElement($elem, $Depth=0) {
	switch($elem.Name) {
		NewLine {
			$script:Writer.WriteLine()
			$script:LineStarted = $false
			break
		}
		Comment {
			Write-Text $elem.InnerText
			break
		}
		Table {
			if ($elem.HasChildNodes) {
				Write-Text '@{'
				Write-XmlChild $elem ($Depth + 1)
				Write-Text '}'
			}
			else {
				Write-Text '@{}'
			}
			break
		}
		Array {
			if ($elem.HasChildNodes) {
				Write-Text '@('
				Write-XmlChild $elem ($Depth + 1)
				Write-Text ')'
			}
			else {
				Write-Text '@()'
			}
			break
		}
		Item {
			if ($elem.GetAttribute('Type') -eq 'String') {
				Write-Text ("'{0}' =" -f $elem.Key.Replace("'", "''"))
			}
			else {
				Write-Text ('{0} =' -f $elem.Key)
			}
			Write-XmlChild $elem $Depth
			break
		}
		Number {
			Write-Text $elem.InnerText
			break
		}
		String {
			if ($elem.GetAttribute('Type') -eq '1') {
				Write-Text "@'"
				$script:Writer.WriteLine()
				$script:Writer.Write($elem.InnerText)
				$script:Writer.WriteLine()
				$script:Writer.Write("'@")
			}
			else {
				Write-Text ("'{0}'" -f $elem.InnerText.Replace("'", "''"))
			}
			break
		}
		Variable {
			Write-Text ('${0}' -f $elem.InnerText)
			break
		}
		Cast {
			Write-Text ($elem.GetAttribute('Type'))
			Write-XmlChild $elem $Depth
			break
		}
		Comma {
			Write-Text ',' -NoSpace
			break
		}
		Semicolon {
			Write-Text ';' -NoSpace
			break
		}
		Block {
			Write-Text ('{{{0}}}' -f $elem.InnerText)
			break
		}
		default {
			throw "Unexpected node '$_'."
		}
	}
}
