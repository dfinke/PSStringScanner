#Requires -Modules PSStringScanner

(Get-Content .\CountryInfo.txt).Scan("[a-zA-z ]+(?=:)")

# $scanner = New-PSStringScanner (Get-Content .\CountryInfo.txt -Raw)

# do {
#     $token = $scanner.Scan("[a-zA-z ]+(?=:)")
#     if ($token) {$token}
# } until($null -eq $token)

# do {
#     $token = $scanner.Scan("[a-zA-z ]+(?=:)")
#     if ($token) {
#         $null = $scanner.Scan(":")
#         $Amt = $scanner.ScanUntil("\r\n").trim()
#         [PSCustomObject][Ordered]@{
#             Country = $token
#             Amt     = [double]::Parse($Amt)
#         }
#     }
# } until($null -eq $token)