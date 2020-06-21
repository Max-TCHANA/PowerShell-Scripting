#My Servicenow username
$SnowUsername = "admin"
#My Servicenow password
$SnowPlainPassword = "admin@123"
#My Servicenow instance URL:https://dev81253.service-now.com
$SnowBaseURL="https://dev81253.service-now.com/"
#The ticket number of the existing ticket for which I want to retrieve related information
$TicketNumber ="INC0010111"

#Authentication information
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $SnowUsername, $SnowPlainPassword))) 

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/xml')
$headers.Add('Content-Type','application/xml')

# URI (Uniform Resource Identifier) of the specific incident for which I want to fetch information
$uri = $SnowBaseURL + "api/now/table/incident?number=$TicketNumber"

# Specify HTTP method. The possible value are GET, POST, PUT and DELETE
$method = "get"

# Send HTTP request
[xml]$response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -UseBasicParsing

#Displaying fetched information
$response.ChildNodes.result
