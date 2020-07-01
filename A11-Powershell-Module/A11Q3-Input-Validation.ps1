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
