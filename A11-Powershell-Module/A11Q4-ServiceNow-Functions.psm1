####### Global Variable ########

#My Servicenow username
$Global:SnowUsername = "admin"
#My Servicenow password
$Global:SnowPlainPassword = Get-Content 'C:\MyServiceNow-Instance-Password.txt' | ConvertTo-SecureString
#Converting from securestring to plaintext
$Global:SnowPlainPassword =  [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Global:SnowPlainPassword))
#My Servicenow instance URL:https://dev81253.service-now.com
$Global:SnowBaseURL="https://dev81253.service-now.com/"

#Authentication information
$Global:base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Global:SnowUsername, $Global:SnowPlainPassword))) 

# Set proper headers
$Global:headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Global:headers.Add('Authorization',('Basic {0}' -f $Global:base64AuthInfo))
$Global:headers.Add('Accept','application/xml')
$Global:headers.Add('Content-Type','application/xml')
###############################

cd "C:\Program Files\WindowsPowerShell\Modules\ServiceNow-Functions"

#.\A11Q1-Function-ServiceNow-GetIncident.ps1
#.\A11Q2-Function-ServiceNow-UpdateIncident.ps1
#.\Input-Validation.ps1

#### First Function
function Input-Validation ($TicketNumber =$(Throw "You should provide an Incident ticket number. 
`n Here is an example of valid input: INC0010111"))
{
#Ticket Number prefix
$Prefix=$TicketNumber[0] + $TicketNumber[1] + $TicketNumber[2]
#Ticket Number suffix
$Suffix = $TicketNumber.remove(0,3)  
    
    
    if ($Prefix -ne "INC" -or $Suffix.Length -ne 7 -or ($Suffix -match "[^0-9]") -eq "True" ){
        Return "False"
    }
    else{ Return "True"}
}


#### Second Function
function ServiceNow-GetIncident ($TicketNumber =$(Throw "You should provide an Incident ticket number. 
`n Here is an example of valid input: INC0010111")){
#This function allows to fetch an Incident object. One input is required: Incident TicketNumber

#Error management
$ErrorActionPreference = "SilentlyContinue"

################ Start of Input validation Process

    if ((Input-Validation($TicketNumber)) -eq "False" ){
        echo "The Ticket number provided is not correct.Here is an example of valid input: INC0010111 "
        Break
    }
    ################ End of Input validation process
    else{
        

        # URI (Uniform Resource Identifier) of the specific incident for which I want to fetch information
        $uri = $Global:SnowBaseURL + "api/now/table/incident?number=$TicketNumber"

        # Specify HTTP method. The possible value are GET, POST, PUT and DELETE
        $method = "get"

        # Send HTTP request
        [xml]$response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -UseBasicParsing

        #Displaying fetched information
        return $response.ChildNodes.result
        #Cleanup
        #Remove-Variable -Name * 2> $null
        
    }
}

#### Third Function
function ServiceNow-UpdateIncident {
#This function allows to Uptade an existing Incident ticket. Three input are required: TicketNumber, tragetted IncidentState and associated IncidentWorkNotes

param ($TicketNumber =$(Throw "You should provide an Incident ticket number. 
`n Here is an example of valid input: INC0010111"), 
[string][ValidateSet("New","In Progress","On Hold","Resolved","Closed","Canceled")]$IncidentState, 
[String]$IncidentWorkNotes=$(Throw "Worknotes are mandatory. Please provide some comments."))

#Error management
$ErrorActionPreference = "SilentlyContinue"

################ Start of Input validation Process

    if ((Input-Validation($TicketNumber)) -eq "False" ){
        echo "The Ticket number provided is not correct.Here is an example of valid input: INC0010111 "
        Break
    }
    ################ End of Input validation process
    else{

        #Getting Incident Sys_id
        $IncidentSysId= (ServiceNow-GetIncident -TicketNumber $TicketNumber).sys_id
        
        
        
        # URI (Uniform Resource Identifier) of the specific incident for which I want to fetch information
        $uri = $Global:SnowBaseURL + "api/now/table/incident/$IncidentSysId"

        # Specify HTTP method. The possible value are GET, POST, PUT and DELETE
        $method = "patch"

        # Specify request body
        
        switch ($IncidentState)
        {
            "New" {$IncidentState = 1}
            "In Progress" {$IncidentState = 2}
            "On Hold" {$IncidentState = 3}
            "Resolved" {$IncidentState = 4}
            "Closed" {$IncidentState = 5}
            "Canceled" {$IncidentState = 6}
          
        }
        $body = "<request><entry><incident_state>$IncidentState</incident_state><work_notes>$IncidentWorkNotes</work_notes></entry></request>"        

        # Send HTTP request
        [xml]$response = Invoke-WebRequest -Headers $headers -Method $method -Body $body -Uri $uri -UseBasicParsing

        #Displaying fetched information
        $response.ChildNodes.result
        #$response.ChildNodes.result.sys_id
        #Cleanup
        #An echo for testing purposes
        #echo " IncidentSysId = $IncidentSysId `n IncidentState = $IncidentState `n IncidentWorkNotes = $IncidentWorkNotes `n body = $body `n method = $method "
    }
}

#region export module member

export-modulemember -function  *

Cd "C:\"