$manifestPath = "$PSScriptRoot\..\PSStringScanner.psd1"
Import-Module $manifestPath -Force

Describe "TypeData" {
    It "Should Scan" {
        $actual = "The quick brown fox".Scan("\w+")

        $actual.Count | Should Be 4
        $actual[0] | Should BeExactly "The"
        $actual[1] | Should BeExactly "quick"
        $actual[2] | Should BeExactly "brown"
        $actual[3] | Should BeExactly "fox"
    }

    It "Should Parse" {
        $actual = "The quick brown fox".Parse("[a-z]+")

        $actual | Should BeExactly "he"
    }
}