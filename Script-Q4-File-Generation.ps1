
$StopWatch = [System.Diagnostics.stopwatch]::StartNew() # This variable allows getting accurate execution time calculations for this Powershell script

 <# This script create a file containing the following information:
1 Script Author
2 File generation Date and Time
3 Time taken to generate file
4 The NIC information for the current laptop
5 Global Variables of in the current PC are
#>

#Creating the file that contains the information
New-Item -Path C:\ -Name "pc-info.txt" -ItemType File -Force

#Filling the header of the file
"**********************************************************" >> C:\pc-info.txt
"*Script Author : Max TCHANA                              *" >> C:\pc-info.txt
"*File generation Date and Time: $(Get-Date)      *" >> C:\pc-info.txt
"*Time taken to generate file: 000 Milliseconds           *" >> C:\pc-info.txt
"**********************************************************`n" >> C:\pc-info.txt

"##########################################################" >> C:\pc-info.txt
"The NIC information for the current laptop is -           " >> C:\pc-info.txt
"##########################################################" >> C:\pc-info.txt

# Executing ipconfig command
ipconfig.exe >> C:\pc-info.txt

"`n##########################################################" >> C:\pc-info.txt
"Global Variables of in the current PC are                 " >> C:\pc-info.txt
"##########################################################" >> C:\pc-info.txt

#Executing Get-Variable command and remove the $StopWatch variable from the list. Applying Format table

Get-Variable | Where-Object {$_.Name -ne "StopWatch"} | FT >> C:\pc-info.txt

#Replacing the 3rd line of the header of the pc-info.txt file
$fileContent = Get-Content C:\pc-info.txt
$fileContent[3] = "*Time taken to generate file: $($StopWatch.Elapsed.Milliseconds) Milliseconds          *"

#Stopping the Stopwatch
$StopWatch.Stop()
#Modifying the pc-info.txt file content
$fileContent | Set-Content C:\pc-info.txt