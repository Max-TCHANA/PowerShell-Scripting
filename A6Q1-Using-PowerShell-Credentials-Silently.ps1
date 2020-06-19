<#This allows to Pass Credentials silently to the -credential parameter in invoke-command#>
#Our goal is Using PowerShell credentials without being prompted for a password


#Getting password securely and storing it locally as a securestring. THIS HAS TO BE DONE JUST ONCE
read-host -assecurestring | convertfrom-securestring | out-file C:\mysecurestring.txt

$TargetServer = "1.1.2.23" 
$RemoteUser = "remote"
$RemotePassword = Get-Content 'C:\mysecurestring.txt' | ConvertTo-SecureString
#Storing credential in a variable
$Creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $RemoteUser, $RemotePassword


#Using the Invoke-Command with the stored credentials

Invoke-Command -ComputerName $TargetServer -Credential $Creds -ScriptBlock { ipconfig }