<#

pos Length Value String           Pattern
--- ------ ----- ------           -------
  0      5 hello hello 123 hi 234 \w+
  5      3 123   hello 123 hi 234 \w+
  9      2 hi    hello 123 hi 234 \w+
 12      3 234   hello 123 hi 234 \w+


pos Length Value String           Pattern
--- ------ ----- ------           -------
  0      3 123   hello 123 hi 234 \d+
  9      3 234   hello 123 hi 234 \d+


pos Length Value String               Pattern
--- ------ ----- ------               -------
  0      5 hello hello 123 there234hi [a-zA-Z]+
  5      5 there hello 123 there234hi [a-zA-Z]+
 15      2 hi    hello 123 there234hi [a-zA-Z]+

#>
function Get-AllMatching {
    param(
        $str,
        $pattern
    )

    $scanner = New-PSStringScanner $str

    do {
        $h = [ordered]@{pos = $scanner.pos}

        if ($v = $scanner.Scan($pattern)) {
            $h.Length = $v.length
            $h.Value = $v
            $h.String = $str
            $h.Pattern = $pattern
            [pscustomobject]$h
        }
    } until ($null -eq $v)
}

Get-AllMatching "hello 123 hi 234" \w+ | Format-Table
Get-AllMatching "hello 123 hi 234" \d+ | Format-Table
Get-AllMatching "hello 123 there234hi" [a-zA-Z]+ | Format-Table
