function New-VariablePsd($Text) {
	switch($Text) {
		false {return $false}
		true {return $true}
		null {return $null}
		default {throw "Not supported variable '$_'."}
	}
}
