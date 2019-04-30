$manifestPath = "$PSScriptRoot\..\PSStringScanner.psd1"
Import-Module $manifestPath -Force

Describe "Test match results" {

    It "Should have groups" {
        $scanner = New-PSStringScanner '4.7'

        $scanner.Check('(\d)\.(\d)') | Should Be $true
        $scanner.regexMatch.Groups | Should Not Be Null
        $scanner.regexMatch.Groups.Count | Should Be 3
        $scanner.regexMatch.Groups[1].Value | Should Be 4
        $scanner.regexMatch.Groups[2].Value | Should Be 7

        $matches = $scanner.Matches()
        $matches.Count | Should Be 3
        $matches[1].Value | Should Be 4
        $matches[2].Value | Should Be 7
    }
}
Describe "Test words, whitespace and eos" {
    Context "String being parsed ['This is an example string']" {
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
}

Describe "Test words, whitespace and eos step-by-step" {
    Context "String being parsed ['This is an example string']" {
        $scanner = New-PSStringScanner 'This is an example string'

        It "Verifying not EoS [$($scanner.EoS())]" {
            $scanner.EoS()        | Should Be $false
        }

        It "Next word ['This']" {
            $scanner.Scan("\w+")  | Should BeExactly 'This'
        }

        It "Followed by a space [' ']" {
            $scanner.Scan("\s+")  | Should BeExactly ' '
        }

        It "Next word ['is']" {
            $scanner.Scan("\w+")  | Should BeExactly 'is'
        }

        It "Verifying not EoS [$($scanner.EoS())]" {
            $scanner.EoS()        | Should Be $false
        }

        It "Followed by a space [' ']" {
            $scanner.Scan("\s+")  | Should BeExactly ' '
        }

        It "Next word ['an']" {
            $scanner.Scan("\w+")  | Should BeExactly 'an'
        }

        It "Followed by a space [' ']" {
            $scanner.Scan("\s+")  | Should BeExactly ' '
        }

        It "Next word ['example']" {
            $scanner.Scan("\w+")  | Should BeExactly 'example'
        }

        It "Followed by a space [' ']" {
            $scanner.Scan("\s+")  | Should BeExactly ' '
        }

        It "Next word ['string']" {
            $scanner.Scan("\w+")  | Should BeExactly 'string'
        }

        It "Verifying EoS is [$($scanner.EoS())]" {
            $scanner.EoS()        | Should Be $true
        }
    }
}

Describe "Testing String Scanner with string ['This is an example string']" {
    BeforeAll {
        $script:scanner = New-PSStringScanner 'This is an example string'
    }

    It "First word should be 'This'" {
        $scanner.Scan("\w+") | Should BeExactly "This"
    }

    It "Followed by 'is'" {
        $scanner.Scan("\w+") | Should BeExactly "is"
    }

    It "Followed by 'an'" {
        $scanner.Scan("\w+") | Should BeExactly "an"
    }

    It "Followed by 'example'" {
        $scanner.Scan("\w+") | Should BeExactly "example"
    }

    It "Followed by 'string'" {
        $scanner.Scan("\w+") | Should BeExactly "string"
    }

    It "End Of String should be $($scanner.EOS())" {
        $scanner.EOS() | Should be $true
    }
}

Describe "Test skip method" {
    BeforeAll {
        $script:scanner = New-PSStringScanner 'stra strb strc'
    }

    It "Should return correct length if found" {
        $scanner.Skip("\w+") | Should Be 4
        $scanner.Skip("\s+") | Should Be 1
        $scanner.Skip("\w+") | Should Be 4
        $scanner.Skip("\s+") | Should Be 1
        $scanner.Skip("\w+") | Should Be 4
        $scanner.Skip("\s+") | Should Be $null
        $scanner.Skip("\w+") | Should Be $null
    }
}
Describe "Test check & skip methods" {
    Context "List items being parsed ['Eggs, cheese, onion, potato, peas']" {
        BeforeEach {
            $script:scanner = New-PSStringScanner 'Eggs, cheese, onion, potato, peas'
        }

        It "Should find 'Eggs' first" {
            $actual = $scanner.scan("\w+")
            $actual | Should Be 'Eggs'
        }

        It "Should find 'cheese' next" {
            $null = $scanner.scan("\w+")
            $scanner.Check(',') | Should Be $true
            $scanner.Skip(',\s+')

            $actual = $scanner.scan("\w+")
            $actual | Should BeExactly "cheese"
        }

        It "Should find 'onion' next" {
            $null = $scanner.scan("\w+")
            $null = $scanner.scan("\w+")
            $scanner.Check(',') | Should Be $true
            $scanner.Skip(',\s+')

            $actual = $scanner.scan("\w+")
            $actual | Should BeExactly "onion"
        }

        It "Should find 'potato' next" {
            $null = $scanner.scan("\w+")
            $null = $scanner.scan("\w+")
            $null = $scanner.scan("\w+")
            $scanner.Check(',') | Should Be $true
            $scanner.Skip(',\s+')

            $actual = $scanner.scan("\w+")
            $actual | Should BeExactly "potato"
        }

        It "Should find 'peas' next" {
            $null = $scanner.scan("\w+")
            $null = $scanner.scan("\w+")
            $null = $scanner.scan("\w+")
            $null = $scanner.scan("\w+")
            $scanner.Check(',') | Should Be $true
            $scanner.Skip(',\s+')

            $actual = $scanner.scan("\w+")
            $actual | Should BeExactly "peas"
        }
    }
}

Describe "Test loops on List ['Eggs, cheese, onion, potato, peas']" {

    Context "Generate items With Check() & Skip() methods" {

        $script:scanner = New-PSStringScanner 'Eggs, cheese, onion, potato, peas'

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

        It "Item count should be 5" {
            $actualItems.Count | Should Be 5
        }

        It "Array items ['Eggs, cheese, onion, potato, peas']" {
            $actualItems | Should Be 'Eggs', 'cheese', 'onion', 'potato', 'peas'
        }
    }

    Context "Generate Items with Do {} Until ()" {

        $script:scanner = New-PSStringScanner 'Eggs, cheese, onion, potato, peas'

        $actualItems = do {$scanner.scan("\w+")} until ($scanner.EoS())

        It "Item count should be 5" {
            $actualItems.Count | Should Be 5
        }

        It "Array items ['Eggs, cheese, onion, potato, peas']" {
            $actualItems | Should Be 'Eggs', 'cheese', 'onion', 'potato', 'peas'
        }
    }
}

Describe "Test SkipUntil" {
    BeforeEach {
        $script:scanner = New-PSStringScanner 'Foo Bar Baz'
    }

    It "Check for 'Foo' in string 'Foo Bar Baz' pos [3]" {
        $scanner.SkipUntil("Foo") | Should Be 3
        $scanner.pos              | Should Be 3
    }

    It "Check for 'Bar' in string 'Foo Bar Baz' pos [7]" {
        $scanner.SkipUntil("Bar") | Should Be 7
        $scanner.pos              | Should Be 7
    }

    It "Check for 'Qux' in string 'Foo Bar Baz' pos[`$null] and EoS [`$false]" {
        $scanner.SkipUntil("Qux") | Should Be $null
        $scanner.EoS()            | Should Be $false
    }

    It "Check for '12' in string 'Fri Dec 12 1975 14:39' pos [10]" {
        $script:scanner = New-PSStringScanner 'Fri Dec 12 1975 14:39'
        $scanner.SkipUntil('12') | Should Be 10
    }
}

Describe "Test Terminate" {

    BeforeAll {
        $script:scanner = New-PSStringScanner 'Foo Bar Baz'
    }

    It "Should not be at the EoS" {
        $scanner.EoS() | Should Be $false
    }

    It "Should be at the EoS" {
        $scanner.Terminate()
        $scanner.EoS() | Should Be $true
    }

    It "Should not find Bar" {
        $scanner.Scan("Bar") | Should BeNullOrEmpty
    }
}

Describe "Test CheckUntil" {
    BeforeEach {
        $script:scanner = New-PSStringScanner 'Foo Bar Baz'
    }

    It "Check for 'Foo' in 'Foo Bar Baz'" {
        $scanner.CheckUntil("Foo") | Should Be 'Foo'
        $scanner.pos              | Should Be 0
    }

    It "Check for 'Foo Bar' in 'Foo Bar Baz'" {
        $scanner.CheckUntil("Foo Bar") | Should Be 'Foo Bar'
        $scanner.pos              | Should Be 0
    }

    It "Check for 'Bar' in 'Foo Bar Baz'" {
        $scanner.CheckUntil("Bar") | Should Be "Bar"
        $scanner.pos              | Should Be 0
    }

    It "Check for 'Qux' in 'Foo Bar Baz'" {
        $scanner.CheckUntil("Qux") | Should Be $null
        $scanner.EoS()            | Should Be $false
    }

    It "Check for '12' in 'Fri Dec 12 1975 14:39'" {
        $script:scanner = New-PSStringScanner 'Fri Dec 12 1975 14:39'
        $scanner.CheckUntil("12") | Should Be 12
        $scanner.pos              | Should Be 0
        $scanner.EoS()            | Should Be $false
    }

}

Describe "Test ScanUntil" {
    BeforeEach {
        $script:scanner = New-PSStringScanner 'DougFinke'
    }

    It "Test 'DougFinke'" {
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

Describe "Scan 'The quick brown fox jumped over the lazy dog.'" {
    BeforeAll {
        $script:scanner = New-PSStringScanner "The quick brown fox jumped over the lazy dog."
    }

    It "Position should be 0" {
        $scanner.pos         | Should Be 0
    }

    It "Should be 'The'" {
        $scanner.Scan("The") | Should Be "The"
    }

    It "Position should be 3" {
        $scanner.pos         | Should Be 3
    }

    It "Should be empty string" {
        $scanner.Scan("The") | Should BeNullOrEmpty
    }

    It "Position should be 3" {
        $scanner.pos         | Should Be 3
    }
}

Describe "Test Clone() method" {

    BeforeAll {
        $script:scanner = New-PSStringScanner "The quick brown fox jumped over the lazy dog."
    }

    It "Should Clone" {
        $d = $scanner.Clone()

        $d.s   | Should be $scanner.s
        $d.pos | Should Be $scanner.pos
    }

    It "Only the Clone should change" {

        $d = $scanner.Clone()

        $d.s         | Should Be $scanner.s
        $d.pos       | Should Be $scanner.pos

        $actual = $d.Scan("jumped")

        $actual      | Should BeExactly "jumped"
        $d.pos       | Should Be 26
        $scanner.pos | Should Be 0
    }
}

Describe "Test Clone() method" {

    It "Should find countries" {

        $str = @"
Here are the top ten countries by population, as of 2013 when the
world population was 7 billion.

China:          1,361,540,000
India:          1,237,510,000
United States:    317,234,000
Indonesia:        237,641,326
Brazil:           201,032,714
Pakistan:         185,028,000
Nigeria:          173,615,000
Bangladesh:       152,518,015
Russia:           143,600,000
Japan:            127,290,000
"@

        $countries = "[a-zA-Z ]+:"

        $actual = $str.Scan($countries)

        $actual.Count | Should Be 10
    }

    It "Should return null or empty" {

        $str = @"
Here are the top ten countries by population, as of 2013 when the
world population was 7 billion.

China:          1,361,540,000
India:          1,237,510,000
United States:    317,234,000
Indonesia:        237,641,326
Brazil:           201,032,714
Pakistan:         185,028,000
Nigeria:          173,615,000
Bangladesh:       152,518,015
Russia:           143,600,000
Japan:            127,290,000
"@

        $actual = $str.Scan()
        $actual | Should BeNullOrEmpty
    }
}

Describe "Test Clone() method" {

    It "Should Reset the scan pointer to the beginning" {
        $str = "The quick brown fox jumped over the lazy dog."
        $scanner = New-PSStringScanner $str

        $actual = $scanner.Scan("dog\.")

        $actual      | Should BeExactly "dog."
        $scanner.pos | Should Be $str.Length

        $scanner.Reset()
        $scanner.pos | Should Be 0

        $actual = $scanner.Scan("quick")
        $actual      | Should BeExactly "quick"
        $scanner.pos | Should Be 9
    }
}

Describe "Test Peek" {
    It "Should Peek" {
        $scanner = New-PSStringScanner "test string"

        $scanner.Peek(7)  | Should BeExactly "test st"
        $scanner.Peek(7)  | Should BeExactly "test st"
        $scanner.Scan("test")
        $scanner.Peek(5)  | Should BeExactly " stri"
        $scanner.Peek(10) | Should BeExactly " string"
        $scanner.Scan("string")
        $scanner.Peek(10) | Should BeNullOrEmpty
    }
}

Describe "Test GetCh" {

    It "Should GetCh" {
        $scanner = New-PSStringScanner 'abcde'

        $scanner.GetCh() | Should BeExactly 'a'
        $scanner.GetCh() | Should BeExactly 'b'
        $scanner.GetCh() | Should BeExactly 'c'
        $scanner.GetCh() | Should BeExactly 'd'
        $scanner.GetCh() | Should BeExactly 'e'
        $scanner.GetCh() | Should BeNullOrEmpty
    }

    It "Should GetCh  with Scan" {
        $scanner = New-PSStringScanner 'test string'

        $scanner.GetCh() | Should BeExactly 't'
        $scanner.GetCh() | Should BeExactly 'e'
        $scanner.Scan("str")
        $scanner.GetCh() | Should BeExactly 'i'
        $scanner.GetCh() | Should BeExactly 'n'
        $scanner.GetCh() | Should BeExactly 'g'
        $scanner.GetCh() | Should BeNullOrEmpty
    }
}

Describe "Test unscan" {
    BeforeEach {
        $script:scanner = New-PSStringScanner "test string"
    }

    It "Match should be null if not found" {

    }
}