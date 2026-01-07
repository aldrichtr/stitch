function Import-Psd {
	[OutputType([Hashtable])]
	param(
		[Parameter(Position=0, Mandatory=1, ValueFromPipeline=1)]
		[string] $Path,
		[hashtable] $MergeInto,
		[switch] $Unsafe
	)
	process {
		trap {ThrowTerminatingError $_}

		$Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
		if ($Unsafe) {
			$block = [scriptblock]::Create([System.IO.File]::ReadAllText($Path))
			$data = & $block
		}
		else {
			$data = $null
			Import-LocalizedData -BaseDirectory ([System.IO.Path]::GetDirectoryName($Path)) -FileName ([System.IO.Path]::GetFileName($Path)) -BindingVariable data
		}

		if ($MergeInto) {
			if ($data -isnot [hashtable]) {
				throw 'With MergeInto imported data must be a hastable.'
			}
			foreach($_ in $data.GetEnumerator()) {
				$MergeInto[$_.Key] = $_.Value
			}
		}
		else {
			$data
		}
	}
}
