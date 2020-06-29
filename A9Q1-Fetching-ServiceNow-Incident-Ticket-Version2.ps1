#Error management
#$ErrorActionPreference = "SilentlyContinue"
#My Servicenow username
$SnowUsername = "admin"
#My Servicenow password
$SnowPlainPassword = "Admin@123#"
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

#Cleanup
#Remove-Variable -Name * 2> $null
