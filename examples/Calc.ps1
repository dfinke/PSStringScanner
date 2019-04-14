# http://gafur.me/2018/01/08/ruby-standard-library-stringscanner.html

function Invoke-Calc {
    param($str)

    $Space = '\s+'
    $Digits = '\d+'
    $OperationSymbols = "[-+/*]"

    $scanner = New-PSStringScanner $str

    [int]$first = $scanner.Scan($Digits)
    $null = $scanner.Scan($Space)
    $operation = $scanner.Scan($OperationSymbols)
    $null = $scanner.Scan($this.SPACE)
    [int]$second = $scanner.Scan($Digits)

    switch ($operation) {
        '+' {$first + $second}
        '-' {$first - $second}
        '*' {$first * $second}
        '/' {$first / $second}
    }
}

Invoke-Calc '2 +3'
Invoke-Calc '10 - 9'
Invoke-Calc ' 10 * 9'
Invoke-Calc '10 / 5 '