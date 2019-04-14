# https://www.rubyguides.com/2015/04/parsing-with-ruby/

class Parser {
    hidden $buffer
    [Tag[]]$tags = @()

    Parser($s) {
        $this.buffer = New-PSStringScanner $s
        $this.parse()
    }

    parse() {
        while (!$this.buffer.EoS()) {
            $this.parse_element()
            $this.skip_spaces()
        }
    }

    parse_element() {
        if ($this.buffer.Peek(1) -eq '<') {
            $this.tags += $this.find_tag()
            $this.last_tag().content = $this.find_content()
        }
    }

    [string]find_content() {
        $tag = $this.last_tag().name
        $content = $this.buffer.ScanUntil("<\/$($tag)>")

        return ($content -replace "</$($tag)>", "")
    }

    [Tag]find_tag() {
        $this.buffer.GetCh()
        $tag = $this.buffer.scan('\w+')
        $this.buffer.GetCh()

        return [Tag]::new($tag)
    }

    skip_spaces() {
        $this.buffer.skip('\s+')
    }

    [Tag]last_tag() {
        return $this.tags[-1]
    }
}

class Tag {
    $name
    $content

    Tag($name) {
        $this.name = $name
    }
}

$html = @"
<body>testing</body>
<title>parsing with ruby</title>
"@

[Parser]::new($html).tags