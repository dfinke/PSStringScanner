$author = "^Author: "
$date = "^Date: "
$commitMsg = "^\s+"

foreach ($line in ((git log --first-parent) -split "\r?\n")) {

    $scanner = New-PSStringScanner $line

    if ($scanner.Check($author)) {
        $null = $scanner.Scan($author)
        $name = $scanner.ScanUntil("\s(?=<)")
        $null = $scanner.Scan("<")
        $email = $scanner.ScanUntil(".*(?=>)")
        $null = $scanner.Scan(">")

    }
    elseif ($scanner.Check($date)) {
        $null = $scanner.Scan($date)
        $null = $scanner.Scan("\s+")
        $theDate = $scanner.Scan(".*")

        $format = "ddd MMM d HH:mm:ss yyyy K"
        $theDate = [datetime]::ParseExact($theDate, $format, $null)

    }
    elseif ($scanner.Check($commitMsg)) {
        $null = $scanner.Scan($commitMsg)
        $message = $scanner.Scan(".*")

        [PSCustomObject]@{
            Name          = $name
            Email         = $email
            Date          = $theDate
            CommitMessage = $message
        }
    }
}