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
