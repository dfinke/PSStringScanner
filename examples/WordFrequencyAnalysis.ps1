Import-Module PSStringScanner

# word frequency analysis text

$text = @"
This line occurs only once.
 This line occurs twice.
 This line occurs twice.
 This line occurs three times.
 This line occurs three times.
 This line occurs three times.
"@

$ss = New-PSStringScanner $text

$(do {
        $w = $ss.Scan("\w+")
        $w
    } until($null -eq $w)) |
Group-Object -NoElement |
Sort-Object Count -Descending