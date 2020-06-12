<#
This script lists all services on your system whose name start with letters "a, s, d, f" 
and have their current status as stopped in descending order.
#>

Get-Service | Where-Object {$_.Name -like "a*" -or $_.Name -like "s*" -or $_.Name -like "d*" -or $_.Name -like "f*" -and $_.Status -eq "Stopped"} | Sort-Object -Property Name -Descending