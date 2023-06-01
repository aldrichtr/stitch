param(
    # The type of file to create
    [Parameter(
        Position = 0
    )]
    [string]$Type,

    # The file name
    [Parameter(
        Position = 1
    )]
    [string]$Name,

    # The data to pass into the template binding
    [Parameter(
        Position = 2
    )]
    [hashtable]$Data,

    # The directory to place the new file in
    [Parameter()]
    [string]$Destination,


    # The source directory for templates
    [Parameter(
    )]
    [string]$TemplateDir = '.\tools\templates'
)

$templateMap = @{}
foreach ($file in (Get-ChildItem $TemplateDir -Filter '*.eps1')) {
    $templateMap[$file.BaseName] = @{
        Path = $file.FullName
    }
}

if (-not($PSBoundParameters.ContainsKey('Name'))) {
    $Name = $Type
}

if ($templateMap.ContainsKey($Type)) {
    $filePath = $templateMap[$Type].Path
    $content = Get-Content $filePath -Raw

    #TODO: Here I could replace an "include cookie" with the content of whatever file
    # like : $content -replace '<#:\s+Include\(\s*(.*)\s*\)' , (Get-Content (join-path $TemplateDir $1))

    $null = $content -match '(?sm)---(.*?)---'
    if ($Matches.Count -gt 0) {
        $outOptions = ($ExecutionContext.InvokeCommand.ExpandString( $Matches.1)) | ConvertFrom-Yaml
        $Matches.clear()
    } else {
        Write-Verbose "No YAML header found in $Type template"

    }

    if (-not($outOptions.ContainsKey('Extension'))){
        $outOptions['Extension'] = '.ps1'
    }


    if ($outOptions.ContainsKey('Destination')) {
        $Destination = $outOptions.Destination
    } elseif (-not($PSBoundParameters.ContainsKey('Destination'))) {
        $Destination = Get-Location
    }

    if ($null -eq $Data) {
        $Data = @{}
    }

    $possibleDirectory = $Name | Split-Path

    if ($null -ne $possibleDirectory) {
        $subDirectory = $possibleDirectory
        Remove-Variable possibleDirectory
        $Name = $Name | Split-Path -Leaf
    } else {
        #! Join-Path will throw an error if given a null value, but an empty string is ok
        $subDirectory = ''
    }

    $Data['Name'] = $Name



    $epsOptions = @{
            Template = $content
            #? probably will never be null, because it will always have 'Name'
            Binding = ($Data ?? @{})
            Safe = $true
    }

    $outputPath = (Join-Path $Destination $subDirectory "$Name$($outOptions.Extension)")


    $templateOutput = Invoke-EpsTemplate @epsOptions
    if ($null -ne $templateOutput) {
        if ($null -ne $outputPath) {
            $templateOutput | Set-Content $outputPath
            if (Test-Path $outputPath) {
                $psEditor.Workspace.OpenFile($outputPath)
            }
        }
    } else {
        throw "Template returned no output"
    }
} else {
    throw "No template found for $Type"
}
