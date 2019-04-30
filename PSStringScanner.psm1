# https://github.com/ruby/strscan

class PSStringScanner : ICloneable {
    $pos = 0
    [string]$s
    [System.Text.RegularExpressions.Match]$regexMatch

    PSStringScanner($s) {
        $this.s = $s
    }

    [object]Matches() {
        if ($null -ne $this.regexMatch.Groups) {
            return $this.regexMatch.Groups
        }

        return $null
    }

    Hidden [System.Text.RegularExpressions.Match]MatchResult([string]$value) {
        [regex]$p = $value

        $result = $p.Match($this.s, $this.pos)
        if ($result.Success) {
            $this.regexMatch = $result
        }
        else {
            $this.regexMatch = $null
        }

        return $result
    }

    [object] Scan([string]$value) {
        $result = $this.MatchResult($value)
        if ($result.success) {
            $this.pos = $result.Index + $result.Length
            return $result.Value
        }

        return $null
    }

    [bool]Check($value) {
        $result = $this.MatchResult($value)

        return $result.success
    }

    [object]Skip($value) {
        $result = $this.MatchResult($value)
        if ($result.success) {
            $this.pos = $result.Index + $result.Length
            return $result.Length
        }

        return $null
    }

    <#
        It "checks" to see whether a scan_until will return a value
    #>
    [object]CheckUntil($value) {
        $result = $this.MatchResult($value)
        if ($result.Success) {
            return $result.Value
        }

        return $null
    }

    <#
        Advances the scan pointer until pattern is matched and consumed. Returns the number of bytes advanced, or null if no match was found.

        Look ahead to match pattern, and advance the scan pointer to the end of the match. Return the number of characters advanced, or null if the match was unsuccessful.

        It's similar to ScanUntil, but without returning the intervening string.
    #>
    [object]SkipUntil([string]$value) {
        $result = $this.MatchResult($value)

        if ($result.Success) {
            $this.pos = $result.Index + $value.Length
            return $this.pos
        }

        return $null
    }

    <#
        Scans the string until the pattern is matched. Returns the substring up to and including the end of the match, advancing the scan pointer to that location. If there is no match, null is returned
    #>
    [object]ScanUntil($value) {
        $result = $this.MatchResult($value)

        if ($result.Success) {
            $retVal = $this.s.Substring($this.pos, $result.Index + $result.Length - $this.pos)
            $this.pos = $result.Index + $result.Length
            return $retVal
        }

        return $null
    }

    Terminate() {
        $this.pos = $this.s.Length
    }

    [bool]EoS() {
        return ($this.pos -eq $this.s.Length)
    }

    Reset() {
        $this.pos = 0
    }

    <#
        call-seq: peek(len)

        Extracts a string corresponding to string[pos,len], without advancing the scan pointer.

          $s = New-PSStringScanner 'test string'
          $s.peek(7)          # => "test st"
          $s.peek(7)          # => "test st"
    #>
    [object]Peek($length) {
        if ($length + $this.pos -gt $this.s.length) {
            $length = $this.s.length - $this.pos
        }

        return $this.s.substring($this.pos, $length)
    }

    <#
        Scans one character and returns it.
            $s = New-PSStringScanner "ab"
            $s.GetCh()  # => "a"
            $s.GetCh()  # => "b"
            $s.GetCh()  # => $null
    #>
    [object]GetCh() {

        if ($this.EoS()) {
            return $null
        }

        $retVal = $this.s.substring($this.pos, 1)
        $this.pos += 1

        return $retVal
    }

    [Object] Clone() {

        $newPSStringScanner = [PSStringScanner]::new($this.s)
        $newPSStringScanner.pos = $this.pos

        return $newPSStringScanner
    }

    UnScan() {
        if ($null -ne $this.regexMatch) {
            $this.pos -= $this.regexMatch.Length
            $this.regexMatch = $null
        }
        else {
            throw "ScanError: unscan failed: previous match record not exist"
        }
    }
}

class PSStringScannerEx : PSStringScanner {
    PSStringScannerEx($s) : base($s) {}

    [object]NextWord() {
        return $this.Scan("\w+")
    }

    [object]NextNumber() {
        return $this.Scan("\d+")
    }

    [object]NextLine() {
        return $this.Scan("\r?\n")
    }
}

function New-PSStringScanner {
    param(
        [Parameter(Mandatory)]
        $text
    )

    [PSStringScanner]::new($text)
}

function New-PSStringScannerEx {
    param(
        [Parameter(Mandatory)]
        $text
    )

    [PSStringScannerEx]::new($text)
}

Update-TypeData -Force -TypeName String -MemberType ScriptMethod -MemberName Scan -Value {
    param($v)

    $scanner = New-PSStringScanner $this
    do {
        $token = $scanner.Scan($v)
        if ($null -ne $token) {$token}
    } until([string]::IsNullOrEmpty($token))
}

Update-TypeData -Force -TypeName String -MemberType ScriptMethod -MemberName Parse -Value {
    param($v)

    $scanner = New-PSStringScanner $this
    return $scanner.Scan($v)
    # $null = $scanner.Scan($v)
    # return $scanner
}