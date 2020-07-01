
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


