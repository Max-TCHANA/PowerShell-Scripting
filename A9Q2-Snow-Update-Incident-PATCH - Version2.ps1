# This script Update Existing ServiceNow Incident
# Script will update existing ServiceNow Incident via Powershell
#Ref: https://childebrandt42.wordpress.com/2018/10/28/service-now-incident-creation-and-updating-with-powershell/

#Error management
#$ErrorActionPreference = "SilentlyContinue"

#ServiceNow creds
$user = "admin"
$pass = "Admin@123#"
#My Servicenow instance URL:https://dev81253.service-now.com
$SnowBaseURL="https://dev81253.service-now.com/"

################ Start of Input validation Process
#Ticket Number prefix
$Prefix="A"
#Ticket Number suffix
$Suffix ="111"


    do {echo "Here is an example of valid input: INC0010111 "
         $TicketNumber = Read-Host "Please Enter an Incident Number "
         $Prefix=$TicketNumber[0] + $TicketNumber[1] + $TicketNumber[2]
         $Suffix = $TicketNumber.remove(0,3)
        
     }While ($Prefix -ne "INC" -or $Suffix.Length -ne 7 -or ($Suffix -match "[^0-9]") -eq "True" )
################ End of Input validation process

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')


#URI
$uri = $SnowBaseURL + "api/now/table/incident?number=$TicketNumber"

# Specify HTTP method
$method = "patch"

# Specify request body
#Changing Incident state
$body = @{ #Create Body of the Post Request
incident_state="2"
}

<#We can use this $body2 to update incident notes, close_notes, work_notes
$body2 = @{ #Create Body of the Post Request
work_notes="Update Work Notes"
close_notes="Your Close Notes"
}#>

$bodyjson = $body | ConvertTo-Json

# Send HTTP request
$response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -Body $bodyjson -ContentType "application/json"
#$response = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri -Body $bodyjson

# Print response
$response.RawContent
#Cleanup
Remove-Variable -Name * 2> $null