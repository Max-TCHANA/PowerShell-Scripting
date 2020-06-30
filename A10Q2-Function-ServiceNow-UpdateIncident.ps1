function ServiceNow-UpdateIncident {
#This function allows to Uptade an existing Incident ticket. Three input are required: TicketNumber, tragetted IncidentState and associated IncidentWorkNotes

param ($TicketNumber =$(Throw "You should provide an Incident ticket number. 
`n Here is an example of valid input: INC0010111"), 
[string][ValidateSet("New","In Progress","On Hold","Resolved","Closed","Canceled")]$IncidentState, 
[String]$IncidentWorkNotes=$(Throw "Worknotes are mandatory. Please provide some comments."))

#Error management
$ErrorActionPreference = "SilentlyContinue"
#My Servicenow username
$SnowUsername = "admin"
#My Servicenow password
$SnowPlainPassword = "Admin@123#"
#My Servicenow instance URL:https://dev81253.service-now.com
$SnowBaseURL="https://dev81253.service-now.com/"



################ Start of Input validation Process
#Ticket Number prefix
$Prefix=$TicketNumber[0] + $TicketNumber[1] + $TicketNumber[2]
#Ticket Number suffix
$Suffix = $TicketNumber.remove(0,3)

    if ($Prefix -ne "INC" -or $Suffix.Length -ne 7 -or ($Suffix -match "[^0-9]") -eq "True" ){
        echo "The Ticket number provided is not correct.Here is an example of valid input: INC0010111 "
        Break
    }
    ################ End of Input validation process
    else{
        #Authentication information
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $SnowUsername, $SnowPlainPassword))) 

        # Set proper headers
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
        $headers.Add('Accept','application/xml')
        $headers.Add('Content-Type','application/xml')

        #Getting Incident Sys_id
        $IncidentSysId= (ServiceNow-GetIncident -TicketNumber $TicketNumber).sys_id
        
        
        
        # URI (Uniform Resource Identifier) of the specific incident for which I want to fetch information
        $uri = $SnowBaseURL + "api/now/table/incident/$IncidentSysId"

        # Specify HTTP method. The possible value are GET, POST, PUT and DELETE
        $method = "patch"

        # Specify request body
        
        switch ($IncidentState)
        {
            "New" {$body = "<request><entry><incident_state>1</incident_state><work_notes>$IncidentWorkNotes</work_notes></entry></request>"}
            "In Progress" {$body = "<request><entry><incident_state>2</incident_state><work_notes>$IncidentWorkNotes</work_notes></entry></request>"}
            "On Hold" {$body = "<request><entry><incident_state>3</incident_state><work_notes>$IncidentWorkNotes</work_notes></entry></request>"}
            "Resolved" {$body = "<request><entry><incident_state>4</incident_state><work_notes>$IncidentWorkNotes</work_notes></entry></request>"}
            "Closed" {$body = "<request><entry><incident_state>5</incident_state><work_notes>$IncidentWorkNotes</work_notes></entry></request>"}
            "Canceled" {$body = "<request><entry><incident_state>6</incident_state><work_notes>$IncidentWorkNotes</work_notes></entry></request>"}
          
        }
                

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