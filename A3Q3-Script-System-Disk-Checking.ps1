<#
That script works for n number of disks on a system and does the following tasks.
- Counts the number of disk drives in a system.
- Lists the space occupied on the disk in KB's
- Lists the free space available on the drive in MB's
#>
# This script does not consider PowerShell virtual drives. 

#Getting information related to all drives in the system
$DrivesInfo = Get-PSDrive | Where-Object{$_.Provider -like "*FileSystem*"}

#Counts the number of disk drives in a system
Write-Output "`n`nNumber of Drives in the system: $($DrivesInfo.count) `n"
 
#Listing used space(KB) and free space (MB) on each dirve
foreach ($i in 0..($DrivesInfo.count-1)){
Write-Output "****** Info related to drive $($DrivesInfo[$i].Name) ******"
write-output "1.Occupied Space (KB): $($($DrivesInfo[$i].Used)/1KB)"
write-output "2.Free Space (GB): $($($DrivesInfo[$i].Free)/1GB)"
Write-Output "*************************************`n"

}
