#Requires -Modules PSStringScanner

$tests = @"
pick carrier from LINE_IN
place carrier at DB101_IN
pick carrier from DB101_OUT
place carrier at WB500_IN
pick carrier from WB500_OUT
place carrier at LINE_OUT
scan DB101_OUT
"@ -split "`n"

function New-RobotCmd {
    param($verb, $location)

    [PSCustomObject][Ordered]@{
        Verb     = $verb
        Location = $location
    }
}

foreach ($test in $tests) {
    $GetLocation = {
        $null = $scanner.Skip("\s+")
        $scanner.ScanUntil("\w+_\w+")
    }

    $scanner = New-PSStringScanner $test

    $verb = $scanner.Scan('(pick|place|scan)')

    switch ($verb) {
        'pick' {
            $null = $scanner.ScanUntil("carrier")
            $null = $scanner.ScanUntil("from")

            New-RobotCmd $verb (&$GetLocation)
        }

        'place' {
            $null = $scanner.ScanUntil("carrier")
            $null = $scanner.ScanUntil("at")

            New-RobotCmd $verb (&$GetLocation)
        }

        'scan' {
            New-RobotCmd $verb (&$GetLocation)
        }

        default {}
    }
}