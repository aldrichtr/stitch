function Find-BlockEnd {
	while($script:Queue.Count) {
		$t1 = $script:Queue.Dequeue()
		switch($t1.Type) {
			GroupEnd {
				if ($t1.Content -eq '}') {
					return $t1
				}
				break
			}
			GroupStart {
				if ($t1.Content -eq '@{' -or $t1.Content -eq '{') {
					$null = Find-BlockEnd
				}
				break
			}
		}
	}
	throw 'Cannot find block end.'
}
