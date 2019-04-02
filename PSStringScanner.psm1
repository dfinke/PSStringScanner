# https://github.com/ruby/strscan

class PSStringScanner : ICloneable {
    [string]$s
    $pos = 0

    PSStringScanner($s) {
        $this.s = $s
    }

    Hidden [System.Text.RegularExpressions.Match]MatchResult([string]$value) {
        [regex]$p = $value

        return $p.Match($this.s, $this.pos)
    }

    [string] Scan([string]$value) {
        # [regex]$p = $value
        # $result = $p.Match($this.s, $this.pos)
        $result = $this.MatchResult($value)
        if ($result.success) {
            $this.pos = $result.Index + $result.Length
            return $result.Value
        }

        return $null
    }

    [bool]Check($value) {
        # [regex]$p = $value
        # $result = $p.Match($this.s, $this.pos)

        $result = $this.MatchResult($value)

        return $result.success
    }

    [object]Skip($value) {
        # [regex]$p = $value
        # $result = $p.Match($this.s, $this.pos)

        $result = $this.MatchResult($value)
        if ($result.success) {
            $this.pos = $result.Index + $result.Length
            #return $result.Index + $result.Length
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

    [Object] Clone() {

        $newPSStringScanner = [PSStringScanner]::new($this.s)
        $newPSStringScanner.pos = $this.pos

        return $newPSStringScanner
    }
}

function New-PSStringScanner {
    param(
        [Parameter(Mandatory)]
        $text
    )

    [PSStringScanner]::new($text)
}