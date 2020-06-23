#This script allows to Fetch Incident info

#My Servicenow username
$SnowUsername = "admin"
#My Servicenow password
$SnowPlainPassword = "Admin@123#"
#My Servicenow instance URL:https://dev81253.service-now.com
$SnowBaseURL="https://dev81253.service-now.com/"
#My Incident Sys_ID
$YourINCIDENTSys_ID="2b33144e2fe5501064a79bacf699b66f"

#Authentication information
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $SnowUsername, $SnowPlainPassword))) 

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')

##################### FETCHING AN INCIDENT ##########################
# URI (Uniform Resource Identifier) of the specific incident for which I want to fetch information
$uri = $SnowBaseURL + "api/now/table/incident/$YourINCIDENTSys_ID"

# Specify HTTP method. The possible value are GET, POST, PUT and DELETE
$method = "Get"

# Send HTTP request
$response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -UseBasicParsing

#Displaying fetched information
$response.RawContent