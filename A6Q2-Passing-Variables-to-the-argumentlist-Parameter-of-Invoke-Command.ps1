<#
This script shows how to pass variables to the -argumentlist parameter of the Invoke-Command.
The Param keyword and the ArgumentList parameter are used to pass variable values to named parameters in a script block. 

#>

#Getting password securely and storing it locally as a securestring. THIS HAS TO BE DONE JUST ONCE
read-host -assecurestring | convertfrom-securestring | out-file C:\mysecurestring.txt

$TargetServer = "1.1.2.23" 
$RemoteUser = "remote"
$RemotePassword = Get-Content 'C:\mysecurestring.txt' | ConvertTo-SecureString
#Storing credential in a variable
$Creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $RemoteUser, $RemotePassword


#Variable that are going to be used with the -Argumentlist parameter of the Invoke-Command
$max = "This a test performed by Max"
$Jimmy = "Jimmy will execute another one"

Invoke-Command -ComputerName $TargetServer -Credential $Creds2 -ScriptBlock { param ($val1="aaa", $val2="bbb")

$var1=hostname
Write-Host " $val1 on the machine $var1"
Write-Host "$val2 on the machine $var1"

} -ArgumentList $max, $Jimmy