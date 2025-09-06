function ConvertTo-Psd {
	[OutputType([String])]
	param(
		[Parameter(Position=0, ValueFromPipeline=1)]
		$InputObject,
		[int] $Depth,
		[string] $Indent
	)
	begin {
		$objects = [System.Collections.Generic.List[object]]@()
	}
	process {
		$objects.Add($InputObject)
	}
	end {
		trap {ThrowTerminatingError $_}

		$script:Depth = $Depth
		$script:Pruned = 0
		$script:Indent = Convert-Indent $Indent
		$script:Writer = New-Object System.IO.StringWriter
		try {
			foreach($object in $objects) {
				Write-Psd $object
			}
			$script:Writer.ToString().TrimEnd()
			if ($script:Pruned) {Write-Warning "ConvertTo-Psd truncated $script:Pruned objects."}
		}
		finally {
			$script:Writer = $null
		}
	}
}
