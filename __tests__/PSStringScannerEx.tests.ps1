$manifestPath = "$PSScriptRoot\..\PSStringScanner.psd1"
Import-Module $manifestPath -Force

Describe "ScannerEx Interface" {

    It "Should work" {
        $s = @"
The quick brown fox 10 jumped
over the lazy dog
"@
        $scanner = New-PSStringScannerEx $s

        $scanner.NextWord() | Should BeExactly "The"
        $scanner.NextNumber() | Should Be 10

        if ($IsLinux -or $IsMacOS) {
            $scanner.NextLine() | Should Be ([System.Environment]::NewLine)
        }
        else {
            $scanner.NextLine() | Should Be "`r`n"
        }

        $scanner.NextWord() | Should BeExactly "over"
        $scanner.NextWord() | Should BeExactly "the"
    }
}