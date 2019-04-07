#Requires -Modules PSStringScanner

(Get-Content .\CountryInfo.txt).Scan("[a-zA-z ]+(?=:)")

# $scanner = New-PSStringScanner (Get-Content .\CountryInfo.txt -Raw)
# do {
#     $token = $scanner.Scan("[a-zA-z ]+(?=:)")
#     if ($token) {$token}
# } until($null -eq $token)