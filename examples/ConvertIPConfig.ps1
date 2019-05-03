Import-Module PSStringScanner

$h = [ordered]@{ }

foreach ($record in (ipconfig) -split "\r?\n") {
    if ($record) {
        $scanner = New-PSStringScanner $record

        if ($scanner.Check(':$')) {
            $root = $scanner.ScanUntil("(?=:)")
            $h.$root = [ordered]@{ }
        }
        else {
            $key = $scanner.ScanUntil("(?=:)")
            if ($key) {
                $key = $key.Trim()
                $null = $scanner.Scan(":")
                $value = $scanner.ScanUntil(".*").Trim()

                $h.$root.$key = $value
            }
        }
    }
}

$h