$p = Resolve-Path "$PSScriptRoot\..\PSStringScanner.psd1"

Import-Module $p -Force

Describe "Test words, whitespace and eos" {
    It "Should work" {
        $scanner = New-PSStringScanner 'This is an example string'

        $scanner.EoS()        | Should Be $false
        $scanner.Scan("\w+")  | Should BeExactly 'This'
        $scanner.Scan("\s+")  | Should Be ' '
        $scanner.Scan("\w+")  | Should BeExactly 'is'
        $scanner.EoS()        | Should Be $false
        $scanner.Scan("\s+")  | Should Be ' '
        $scanner.Scan("\w+")  | Should BeExactly 'an'
        $scanner.Scan("\s+")  | Should Be ' '
        $scanner.Scan("\w+")  | Should BeExactly  'example'
        $scanner.Scan("\s+")  | Should Be ' '
        $scanner.Scan("\w+")  | Should BeExactly 'string'
        $scanner.EoS()        | Should Be $true
    }
}

Describe "Testing String Scanner" {
    BeforeAll {
        $script:scanner = New-PSStringScanner 'This is an example string'
    }

    It "Word should be 'This'" {
        $scanner.Scan("\w+") | Should BeExactly "This"
    }

    It "Word should be 'is'" {
        $scanner.Scan("\w+") | Should BeExactly "is"
    }

    It "Word should be 'an'" {
        $scanner.Scan("\w+") | Should BeExactly "an"
    }

    It "Word should be 'example'" {
        $scanner.Scan("\w+") | Should BeExactly "example"
    }

    It "Word should be 'string'" {
        $scanner.Scan("\w+") | Should BeExactly "string"
    }

    It "Word should at End Of String" {
        $scanner.EOS() | Should be $true
    }
}

Describe "Test check & skip methods" {

    BeforeEach {
        $script:scanner = New-PSStringScanner 'Eggs, cheese, onion, potato, peas'
    }

    It "Should find ',' next" {
        $null = $scanner.scan("\w+")
        $scanner.Check(',') | Should Be $true
    }

    It "Should find 'cheese' next" {
        $null = $scanner.scan("\w+")
        $scanner.Check(',') | Should Be $true
        $scanner.Skip(',\s+')

        $actual = $scanner.scan("\w+")
        $actual | Should BeExactly "cheese"
    }
}

Describe "Test loops" {

    BeforeEach {
        $script:scanner = New-PSStringScanner 'Eggs, cheese, onion, potato, peas'
    }

    It "With check & skip" {
        $actualItems = @()
        while ($true) {
            $actualItems += $scanner.scan("\w+")
            if ($scanner.Check(',')) {
                $scanner.Skip(',\s+')
            }
            else {
                break
            }
        }

        $actualItems.Count | Should Be 5
        $actualItems | Should Be 'Eggs', 'cheese', 'onion', 'potato', 'peas'
    }

    It "Do {} Until ()" {
        $actualItems = do {$scanner.scan("\w+")} until ($scanner.EoS())

        $actualItems.Count | Should Be 5
        $actualItems | Should Be 'Eggs', 'cheese', 'onion', 'potato', 'peas'
    }
}

Describe "Test SkipUntil" {
    BeforeEach {
        $script:scanner = New-PSStringScanner 'Foo Bar Baz'
    }

    It "Check for 'Foo'" {
        $scanner.SkipUntil("Foo") | Should Be 3
        $scanner.pos              | Should Be 3
    }

    It "Check for 'Bar'" {
        $scanner.SkipUntil("Bar") | Should Be 7
        $scanner.pos              | Should Be 7
    }

    It "Check for 'Qux'" {
        $scanner.SkipUntil("Qux") | Should Be $null
        $scanner.EoS()            | Should Be $false
    }

    It "Should work" {
        $script:scanner = New-PSStringScanner 'Fri Dec 12 1975 14:39'
        $scanner.SkipUntil('12') | Should Be 10
    }
}

Describe "Test CheckUntil" {
    BeforeEach {
        $script:scanner = New-PSStringScanner 'Foo Bar Baz'
    }

    It "Check for 'Foo'" {
        $scanner.CheckUntil("Foo") | Should Be 'Foo'
        $scanner.pos              | Should Be 0
    }

    It "Check for 'Foo Bar'" {
        $scanner.CheckUntil("Foo Bar") | Should Be 'Foo Bar'
        $scanner.pos              | Should Be 0
    }

    It "Check for 'Bar'" {
        $scanner.CheckUntil("Bar") | Should Be "Bar"
        $scanner.pos              | Should Be 0
    }

    It "Check for 'Qux'" {
        $scanner.CheckUntil("Qux") | Should Be $null
        $scanner.EoS()            | Should Be $false
    }

    It "Check for '12'" {
        $script:scanner = New-PSStringScanner 'Fri Dec 12 1975 14:39'
        $scanner.CheckUntil("12") | Should Be 12
        $scanner.pos              | Should Be 0
        $scanner.EoS()            | Should Be $false
    }

}

Describe "Test ScanUntil" {
    BeforeEach {
        $script:scanner = New-PSStringScanner 'abcädeföghi'
    }

    It "Stuff" {
        $scanner.ScanUntil("ä") | Should Be "abcä"
        $scanner.ScanUntil("ö") | Should Be "defö"
    }
}
