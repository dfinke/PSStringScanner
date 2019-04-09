<p align="center">
<a href="https://dougfinke.visualstudio.com/PSStringScanner/_build?definitionId=17"><img src="https://dougfinke.visualstudio.com/PSStringScanner/_apis/build/status/PSStringScanner-CI?branchName=master"></a>
</p>

<p align="center">
<a href="./LICENSE"><img
src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
<a href="https://www.powershellgallery.com/packages/PSStringScanner"><img
src="https://img.shields.io/powershellgallery/dt/PSStringScanner.svg"></a>
<a href="https://www.powershellgallery.com/packages/PSStringScanner"><img
src="https://img.shields.io/powershellgallery/v/PSStringScanner.svg"></a>
</p>

# PowerShell String Scanner
Provides lexical scanning operations on a String.

Ported from https://github.com/ruby/strscan

# Parsing a Config File

<img src="https://raw.githubusercontent.com/dfinke/PSStringScanner/master/images/ParseConfig.png">

# Usage

```powershell
$scanner = New-PSStringScanner 'This is an example string'

$scanner.EoS()               # -> False
$scanner.Scan("\w+")         # 'This'
$scanner.Scan("\s+")         # ' '
$scanner.Scan("\w+")         # 'is'
$scanner.EoS()               # -> False
$scanner.Scan("\s+")         # ' '
$scanner.Scan("\w+")         # 'an'
$scanner.Scan("\s+")         # ' '
$scanner.Scan("\w+")         # 'example'
$scanner.Scan("\s+")         # ' '
$scanner.Scan("\w+")         # 'string'
$scanner.EoS()               # -> True
```

# More Uses
Two approaches, same results.

## Using Scan, Check and Skip
```powershell
$scanner = New-PSStringScanner 'Eggs, cheese, onion, potato, peas'

$actualItems = @()
while ($true) {
    $actualItems += $scanner.scan("\w+")
    if ($scanner.Check(',')) {
        $scanner.Skip(',\s*')
    }
    else {
        break
    }
}
```

## Using Do {} Until

```powershell
$scanner = New-PSStringScanner 'Eggs, cheese, onion, potato, peas'

$actualItems = do {$scanner.scan("\w+")} until ($scanner.EoS())
```

# ScanUntil

Scans the string until the pattern is matched. Returns the substring up to and including the end of the match, advancing the scan pointer to that location. If there is no match, null is returned.

```powershell
$scanner = New-PSStringScanner 'Fri Dec 12 1975 14:39'

$scanner.ScanUntil("1")   # "Fri Dec 1"
$scanner.ScanUntil("YYZ") # $null
```

# CheckUntil

This returns the value that ScanUntil would return, without advancing the scan pointer. The match register is affected, though.

```powershell
$scanner = New-PSStringScanner 'Fri Dec 12 1975 14:39'

$scanner.CheckUntil("12")   # "Fri Dec 12"
$scanner.pos                # 0
```

# SkipUntil
Advances the scan pointer until pattern is matched and consumed. Returns the number of bytes advanced, or null if no match was found.

Look ahead to match pattern, and advance the scan pointer to the end of the match. Return the number of characters advanced, or null if the match was unsuccessful.

It's similar to ScanUntil, but without returning the intervening string.

```powershell
$scanner = New-PSStringScanner 'Fri Dec 12 1975 14:39'

$scanner.SkipUntil("12")   # 10
$scanner
# s                     pos
# -                     ---
# Fri Dec 12 1975 14:39  10
```
