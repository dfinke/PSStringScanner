Import-Module ..\PSStringScanner.psd1 -Force

$scanner = New-PSStringScanner @"
'Hello,' he (the man) said. (To no one in particular.)
'How are you?' (I am fine they replied.)
"@

$itemsFound = do {
    $null = $scanner.ScanUntil('\(')
    $scanner.ScanUntil('(?=\))')
} until ($scanner.EoS() -Or $null -eq $scanner.CheckUntil('\('))


$itemsFound
"`nTotal=$($itemsFound.Count)"