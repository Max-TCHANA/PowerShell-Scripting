# This script Update Existing ServiceNow Incident
# Script will update existing ServiceNow Incident via Powershell
#Ref: https://childebrandt42.wordpress.com/2018/10/28/service-now-incident-creation-and-updating-with-powershell/


#ServiceNow creds
$user = "admin"
$pass = "Admin@123#"
#My Servicenow instance URL:https://dev81253.service-now.com
$SnowBaseURL="https://dev81253.service-now.com/"
#My Incident Sys_ID
$YourINCIDENTSys_ID="2b33144e2fe5501064a79bacf699b66f"

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')


#URI
$uri = $SnowBaseURL + "api/now/table/incident/$YourINCIDENTSys_ID"

# Specify HTTP method
$method = "patch"

# Specify request body
#Changing Incident state
$body = @{ #Create Body of the Post Request
incident_state="3"
}

<#We can use this $body2 to update incident notes, close_notes, work_notes
$body2 = @{ #Create Body of the Post Request
work_notes="Update Work Notes"
close_notes="Your Close Notes"
}#>

$bodyjson = $body | ConvertTo-Json

# Send HTTP request
$response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -Body $bodyjson -ContentType "application/json"

# Print response
$response.RawContent