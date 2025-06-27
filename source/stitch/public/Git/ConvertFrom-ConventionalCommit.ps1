
function ConvertFrom-ConventionalCommit {
    <#
    .SYNOPSIS
        Convert a git commit message (such as from PowerGit\Get-GitCommit) into an object on the pipeline
    .DESCRIPTION
        A git commit message is technically unstructured text.  However, a long standing convention is to structure
        the message should be a single line title, followed by a blank line and then any amount of text in the body.
        Conventional Commits provide additional structure by adding "metadata" to the title:

        -
        |        |<------ title ----------------------| <- 50 char or less
        |        <type>[optional scope]: <description>
        message
        |        [optional body]                        <- 72 char or less
        |
        |        [optional footer(s)]                   <- 72 char or less
        -
        Recommended types are:
        - build
        - chore
        - ci
        - docs
        - feat
        - fix
        - perf
        - refactor
        - revert
        - style
        - test

    #>
    [CmdletBinding()]
    param(
        # The commit message to parse
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Message,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [object]$Sha,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [object]$Author,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [object]$Committer

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        enum Section {
            NONE = 0
            HEAD = 1
            BODY = 2
            FOOT = 3
        }
    }
    process {
        # This will restart for each message on the pipeline
        # Messages (at least the ones from PowerGit objects) are multiline strings
        $section = [Section]::NONE
        $title = $type = $scope = ''
        $body = [System.Collections.ArrayList]@()
        $footers = @{}
        $breakingChange = $false
        $conforming = $false
        $lineNum = 1
        foreach ($line in ($Message -split '\n')) {
            try {
                Write-Debug "Parsing line #$lineNum : '$line'"
                switch -Regex ($line) {
                    '^#+' {
                        Write-Debug ' - Comment line'
                        continue
                    }
                    #! This may match the head, but also may match a specific kind of footer
                    #! too.  So we check the line number and go from there
                    @'
(?x)              # Matches either a conventional title <type>(<scope>)!: <description>
                  # or a footer of like <type>: <description>
^(?<t>\w+)        # Header must start with a type word
(\((?<s>\w+)\))?  # Optionally a scope in '()'
(?<b>!)?          # Optionally a ! to denote a breaking change
:\s+              # Mandatory colon and a space
(?<d>.+)$         # Everything else is the description
'@              {
                        Write-Debug '  - Head line'
                        # Parse as a heading only if we are on line one!
                        if ($lineNum -eq 1) {
                            $title = $line
                            $type = $Matches.t
                            $scope = $Matches.s ?? ''
                            $desc = $Matches.d
                            $section = [Section]::HEAD
                            $breakingChange = ($Matches.b -eq '!')
                            $conforming = $true
                        } else {
                            Write-Debug '  - Footer'
                            # There could be multiple entries of the same type of footer
                            # such as:
                            # closes #9
                            # closes #7
                            if ($footers.ContainsKey($Matches.t)) {
                                $footers[$Matches.t] += $Matches.d
                            } else {
                                $footers[$Matches.t] = @($Matches.d)
                            }
                            $section = [Section]::FOOT
                        }
                        continue
                    }
                    @'
(?x)              # Matches a git-trailer style footer <type>: <description> or <type> #<description>
^\s*
(?<t>[a-zA-Z0-9-]+)
(:\s|\s\#)
(?<v>.*)$
'@              {
                        Write-Debug '  - Footer'
                        # There could be multiple entries of the same type of footer
                        # such as:
                        # closes #9
                        # closes #7
                        if ($footers.ContainsKey($Matches.t)) {
                            $footers[$Matches.t] += $Matches.d
                        } else {
                            $footers[$Matches.t] = @($Matches.d)
                        }
                        $section = [Section]::FOOT
                        continue
                    }
                    @'
(?x)              # Matches either BREAKING CHANGE: <description> or BREAKING-CHANGE: <description>
^\s*
(?<t>BREAKING[- ]CHANGE)
:\s
(?<v>.*)$
'@              {
                        Write-Debug '  - Breaking change footer'
                        $footers[$Matches.t] = $Matches.v
                        $breakingChange = $true
                    }
                    '^\s*$' {
                        # might be the end of a section, or it might be in the middle of the body
                        if ($section -eq [Section]::HEAD) {
                            # this is our "one blank line convention"
                            # so the next line should be the start of the body
                            $section = [Section]::BODY
                        }
                        continue
                    }
                    Default {
                        #! if the first line is not in the proper format, it will
                        #! end up here:  We can add it as the title, but none of
                        #! the conventional commit specs will be filled
                        if ($lineNum -eq 1) {
                            Write-Verbose "  '$line' does not seem to be a conventional commit"
                            $title = $line
                            $desc = $line
                            $conforming = $false
                        } else {
                            # if it matched nothing else, it should be in the body
                            Write-Debug '  - Default match, adding to the body text'
                            $body += $line
                        }
                        continue
                    }
                }
            } catch {
                throw "At $lineNum : '$line'`n$_"
            }
            $lineNum++
        }

        [PSCustomObject]@{
            PSTypeName       = 'Git.ConventionalCommitInfo'
            Message          = $Message
            IsConventional   = $conforming
            IsBreakingChange = $breakingChange
            Title            = $title
            Type             = $type
            Scope            = $scope
            Description      = $desc
            Body             = $body
            Footers          = $footers
            Sha              = $Sha
            ShortSha         = $Sha.Substring(0, 7)
            Author           = $Author
            Committer        = $Committer

        } | Write-Output
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
