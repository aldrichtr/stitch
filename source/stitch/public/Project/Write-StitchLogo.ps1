
function Write-StitchLogo {
    [CmdletBinding()]
    param(
        # Small or large logo
        [Parameter(
        )]
        [ValidateSet('small', 'large')]
        [string]$Size = 'large',

        # Do not print the logo in color
        [Parameter(
        )]
        [switch]$NoColor
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $stitchEmoji = "`u{1f9f5}"

        $stitchLogoSmall = @'
:2:   ___  _    _  _        _
:2:  / __|| |_ (_)| |_  __ | |_
:2:  \__ \|  _|| ||  _|/ _||   \
:2:  |___/ \__||_| \__|\__||_||_|
'@


        $stitchLogoLarge = @'
:1:-=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=:0:
:1:=-       ________________                                                                        =-:0:
:1:-=      (________________)        xxxxxx    xx        xxxx    xx                 xx              -=:0:
:1:=-:0:        :2:(______      )     :1:    x      x  x  x      x    x  x  x               x  x             =-:0:
:1:-=:0:        :2:(    _____   )     :1:   x    xxxx  x  xxxxx   xxxx   x  xxxxx    xxxx   x   xxx          -=:0:
:1:=-:0:        :2:(      ____  )     :1:   x      x   x      x   xxxx   x      x   x    x  x      x         =-:0:
:1:-=:0:        :2:(        ____)     :1:    xxxx   x  x    xxx   x  x   x    xxx  x   xxx  x       x        -=:0:
:1:=-:0:       _:2:(____________):1:_        x      x   x     x   x  x    x     x  x     x  x  x  x  x       =-:0:
:1:-=      (________________)        xxxxxxx    xxxxxx   xxxx     xxxxxx   xxxxxx  xxxx  xxxx       -=:0:
:1:=-                                                                                               =-:0:
:1:-=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=:0:
'@

    }
    process {
        if ($Size -like 'small') {
            $logoSource = $stitchLogoSmall
        } else {
            $logoSource = $stitchLogoLarge
        }
        if (-not($NoColor)) {
            $colors = @(
                $PSStyle.Reset,
                $PSStyle.Foreground.FromRgb('#b1a986'),
                $PSStyle.Foreground.FromRgb('#0679d0')
            )
        } else {
            $colors = @(
                '',
                '',
                ''
            )
        }
        $logoOutput = $logoSource
         for ($c = 0; $c -lt $colors.Length; $c++) {
            $logoOutput = $logoOutput -replace ":$($c.ToString()):", $colors[$c]
         }
    }
    end {
        $logoOutput
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
