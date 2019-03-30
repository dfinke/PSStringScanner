Import-Module ..\PSStringScanner.psd1 -Force

#region Constants
$NAME = '[a-zA-Z]+'
$WHITESPACE = '\s+'
$QUOTE = '"'
#endregion

Get-Content $PSScriptRoot\logkvp.txt |
ForEach-Object {
    $scanner = New-PSStringScanner ($_)

    $kvp = [Ordered]@{ }

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
    
    [PSCustomObject]$kvp
}