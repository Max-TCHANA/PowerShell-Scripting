<#This script measures latency from the local machine to ICMP servers and keeps logs

https://check-host.net/check-ping
Check the reachability of a host with Ping from USA, Canada, Europe and other places.
No need to ping manually website/server from different places. 
Ping hostname in automatic mode with our online service from many places around the world in one click.

Below are some prerequisites

**** To measure vital signs of the endpoint network, keepslog (including Latency)
Install-Module -Name MultiPing -Force
Import-Module -Name  MultiPing -Force
(Get-Module -Name MultiPing).ExportedCommands

#>


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
Start-MultiPing -FirstAddress 172.246.126.50  -SecondAddress 198.56.183.15 -ThirdAddress 192.157.233.160 -FourthAddress 104.26.0.67 -ReportName "C:\Latency_Test.html"


<#
Node	us4.node.check-host.net
IP	172.246.126.50
Datacenter	BudgetVM MIAMI
ISP	BudgetVM
AS number	AS18978


Node	us1.node.check-host.net
Status	OK
IP	198.56.183.15
Datacenter	BudgetVM LOS ANGELES
ISP	BudgetVM
AS number	AS18978

Node	us3.node.check-host.net
IP	192.157.233.160
Datacenter	BudgetVM DALLAS
ISP	BudgetVM
AS number	AS18978

Node check-host.net

IP 104.26.0.67 
OrgName:        Cloudflare, Inc.
OrgId:          CLOUD14
Address:        101 Townsend Street
City:           San Francisco
StateProv:      CA
PostalCode:     94107
Country:        US

#>
