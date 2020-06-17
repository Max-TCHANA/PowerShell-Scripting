<#This script performs a SpeedTest. It provides upload-download bandwidth average, latency, average bandwidth usage, it measures vital signs of the endpoint network and keeps 
log

Below are some prerequisites

**** To measure upload-download bandwidth average
Install-Module -Name SpeedTester
Import-Module -Name SpeedTester
(Get-Module -Name SpeedTester).ExportedCommands

**** To measure vital signs of the endpoint network, keepslog (including Latency)
Install-Module -Name MultiPing -Force
Import-Module -Name  MultiPing -Force
(Get-Module -Name MultiPing).ExportedCommands

*** To measure average bandwidth's usage of the user/system
Install-Script -Name Bandwidth
Import-Module -Name Bandwidth -Force
(Get-Module -Name Bandwidth).ExportedCommands

**** Get Mac address of a remote host
Install-Script -Name Get-MacAddress

#>

#Displaying Latency (ms), Dowload bandwith (Mbps), Upload bandwidth (Mbps)
Start-SpeedTest

<#
Description of function Start-MultiPing
    
.DESCRIPTION
   MultiPing will generate a html based report to help troubleshoot network problems.
   You can set multiple target to ping. Script will report a html based ping chart report
   that can help you to troubleshoot latency related issues.
        
.PARAMETER FirstAddress
   Define first remote IP to ping. Default value: 8.8.8.8
 
.PARAMETER SecondAddress
   Define second remote IP to ping. Default value: 192.168.0.1
 
.PARAMETER ThirdAddress
   Define third remote IP to ping. Default value: irishtimes.com
 
.PARAMETER FourthAddress
   Define fourth remote IP to ping. Default value: www.bbc.com
    
.PARAMETER ReportName
   Define the name of the report that will be generated. Default value: PingStatistics.HhmlChart.html
 
.EXAMPLE
    Start-Multiping
 
.EXAMPLE
    Start-MultiPing -FirstAddress 4.4.4.4
 
.EXAMPLE
    Start-MultiPing -FirstAddress 4.4.4.4 -ReportName Test.Report
 
#>

# measures vital signs of the endpoint network and keeps log including latency
Start-MultiPing

#measure average bandwidth's usage of the user/system
Bandwidth



