# This scrip lists any 5 Global variable and write their value to a file.

Get-Variable | Select-Object -Last 5 | FL > C:\Five-Global-Variables.txt
