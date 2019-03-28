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
        # $script:scanner = New-PSStringScanner 'abcädeföghi'
        $script:scanner = New-PSStringScanner 'DougFinke'
    }

    It "Stuff" {
        $scanner.ScanUntil("g") | Should Be "Doug"
        $scanner.pos | Should Be 4
        $scanner.ScanUntil("ke") | Should Be "Finke"
        $scanner.pos | Should Be 9
        $scanner.EoS() | Should Be $true

        # Unicode challenges
        #$scanner.ScanUntil("ä") | Should Be "abcä"
        #$scanner.pos | Should Be 4
        #$scanner.ScanUntil("ö") | Should Be "defö"
        #$scanner.pos | Should Be 8
    }
}

Describe "Test Parse Config" {
    It "parse kvp" {
        $scanner = New-PSStringScanner @"
name = "Alice's website"
description = "Alice's personal blog"
url = "http://alice.example.com/"
public = "true"
version = "24"
"@
        $NAME = '[a-z]+'
        $WHITESPACE = '\s+'
        $QUOTE = '"'

        $kvp = [Ordered]@{}

        do {
            $key = $scanner.Scan($NAME)
            $scanner.Skip($WHITESPACE)
            $scanner.Scan('=')
            $scanner.Skip($WHITESPACE)
            $scanner.Scan($QUOTE)
            $value = $scanner.ScanUntil("(?=$QUOTE)")
            $kvp.$key = $value
            $scanner.Scan($QUOTE)
        } until ($scanner.EoS())

        $kvp.Keys.Count | Should Be 5
        $kvp.Contains("name") | Should Be $true
        $kvp.name | Should BeExactly "Alice's website"
        $kvp.Contains("description") | Should Be $true
        $kvp.description | Should BeExactly "Alice's personal blog"
        $kvp.Contains("url") | Should Be $true
        $kvp.url | Should BeExactly "http://alice.example.com/"
        $kvp.Contains("public") | Should Be $true
        $kvp.public | Should BeExactly "true"
        $kvp.Contains("version") | Should Be $true
        $kvp.version | Should Be 24
    }
}

Describe "Quick brown fox" {

    It "Should scan correctly" {

        $scanner = New-PSStringScanner "The quick brown fox jumped over the lazy dog."

        $scanner.pos         | Should Be 0
        $scanner.Scan("The") | Should Be "The"
        $scanner.pos         | Should Be 3
        $scanner.Scan("The") | Should BeNullOrEmpty
        $scanner.pos         | Should Be 3
    }
}