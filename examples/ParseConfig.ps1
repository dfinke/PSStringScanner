Import-Module ..\PSStringScanner.psd1 -Force

$scanner = New-PSStringScanner (Get-Content -Raw $PSScriptRoot\config.txt)

$NAME = '[a-z]+'
$WHITESPACE = '\s+'
$QUOTE = '"'

$kvp = [Ordered]@{}
do {
    $key = $scanner.Scan($NAME)
    $scanner.Skip($WHITESPACE)
    $null = $scanner.Scan('=')
    $scanner.Skip($WHITESPACE)
    $null = $scanner.Scan($QUOTE)
    $value = $scanner.ScanUntil("(?=$QUOTE)")
    $kvp.$key = $value
    $null = $scanner.Scan($QUOTE)
} until ($scanner.EoS())
$kvp