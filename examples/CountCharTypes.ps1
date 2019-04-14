<#

Text        Length Upper Lower Digits Special
----        ------ ----- ----- ------ -------
Amdh#34HB!x     11     3     4      2       2
AzErtY45         8     3     3      2       0
#1A3bhk2         8     1     3      3       1

#>

#requires -Module PSStringScanner

$list = "Amdh#34HB!x", "AzErtY45", "#1A3bhk2"

$(
    foreach ($str in $list) {
        [PSCustomObject][Ordered]@{
            Text    = $str
            Length  = $str.Length
            Upper   = $str.Scan('[A-Z]').Count
            Lower   = $str.Scan('[a-z]').Count
            Digits  = $str.Scan('[0-9]').Count
            Special = $str.Scan('[^a-zA-Z0-9]').Count
        }
    }
) | Format-Table