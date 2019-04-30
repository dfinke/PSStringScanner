# How to parse and sum values from a string

$data = "Cpu(s):  1.9%us,  2.1%sy,  1.5%ni, 94.5%id,  0.8%wa,  0.0%hi,  0.1%si,  0.0%st"

$r = $data.scan("\d{1,2}\.\d")

$r
$r | Measure-Object -Sum -Minimum -Maximum

<#

1.9
2.1
1.5
94.5
0.8
0.0
0.1
0.0

Count    : 8
Average  :
Sum      : 100.9
Maximum  : 94.5
Minimum  : 0
Property :
#>