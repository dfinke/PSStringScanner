# https://blog.appsignal.com/2019/03/05/stringscanner.html

$logentry = @"
Started GET "/" for 127.0.0.1 at 2017-08-20 20:53:10 +0900
Processing by HomeController#index as HTML
  Rendered text template within layouts/application (0.0ms)
  Rendered layouts/_assets.html.erb (2.0ms)
  Rendered layouts/_top.html.erb (2.6ms)
  Rendered layouts/_about.html.erb (0.3ms)
  Rendered layouts/_google_analytics.html.erb (0.4ms)
Completed 200 OK in 79ms (Views: 78.8ms | ActiveRecord: 0.0ms)
"@

$scanner = New-PSStringScanner $logentry

while (!$scanner.Eos()) {
    $log = [Ordered]@{}
    $null = $scanner.skip('Started ')
    $log.Method = $scanner.ScanUntil('[A-Z]+')
    $log.Path = $scanner.Scan('\s"(.+)"').Trim()
    $null = $scanner.skip(' for ')
    $log.IP = $scanner.Scan('[^\s]+').Trim()
    $null = $scanner.skip(' at ')
    $log.TimeStamp = $scanner.ScanUntil('\r').Trim()
    $null = $scanner.SkipUntil('Completed ')
    $log.Success = $scanner.Peek(1) -eq 2
    $log.ResponseCode = $scanner.Scan('\d{3}')
    $null = $scanner.skip(' OK in ')
    $log.Duration = $scanner.ScanUntil('ms')
    $null = $scanner.Scan('\)')
    [PSCustomObject]$log
}