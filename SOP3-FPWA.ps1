# FIREWALL PORT WHITELISTING AZURE - FPWA
# This script allows to perform a Firewall Port Whitelisting on Azure Network Security Group

Param(
[string]$PortNumber= "5556", [string][ValidateSet("TCP","UDP","*")]$Protocol="TCP", 
[string]$DestinationAddress= "20.36.171.131",[string]$NetworkSecurityGroupName= "Autowit-Resource-nsg", [ValidateRange(100,4094) ][int]$PriorityNumber=102)


#########################################################################################################
######################################### GLOBAL VARIABLES ##############################################

# Azure Account Information
$TenantId = "5ca4007e-bd93-4a63-99ac-2a7e8b4dfd32"
$ClientId = "4a306ac7-437a-4cd7-962f-fead39cab4d6"
$ClientSecret = "-~-P78u3sEOW~uTOK9UMT_4M6i7Fh5Bym1"
$Resource = "https://management.core.windows.net/"
$SubscriptionId = "b9772986-7628-4365-a5d2-f2a431b15096"
$ApiVersion ="2020-05-01"

########################################################################################################## 
############### STEP1 Login using Azure API :: Authentication :: Getting a Token  ########################

# PowerShell and Azure REST API Authentication
# Source: https://datathirst.net/blog/2018/9/23/powershell-and-azure-rest-api-authentication

function getBearer([string]$TenantID, [string]$ClientID, [string]$ClientSecret)
{
  $TokenEndpoint = {https://login.windows.net/{0}/oauth2/token} -f $TenantID 
  $ARMResource = "https://management.core.windows.net/";

  $Body = @{
          'resource'= $ARMResource
          'client_id' = $ClientID
          'grant_type' = 'client_credentials'
          'client_secret' = $ClientSecret
  }

  $params = @{
      ContentType = 'application/x-www-form-urlencoded'
      Headers = @{'accept'='application/json'}
      Body = $Body
      Method = 'Post'
      URI = $TokenEndpoint
  }

  $token = Invoke-RestMethod @params
  
  Return $token
  #Return "Bearer " + ($token.access_token).ToString()
}

$token = getBearer $TenantID $ClientID $ClientSecret

    if ($token -ne $null)
    { 

        $ReturnCode = 0
        echo "Step 1: Done : Authentication OK. ReturnCode: $ReturnCode"
    
    }
    else
    {
            $ReturnCode =2
            $ReturnMessage = "Step 1: Failed : Unable to Log in to your Azure account please try again. ReturnCode $ReturnCode" 
            $ReturnMessage
            exit
    }

########################################################################################################## 
######################## STEP2 Check if target NetworkSecurityGroup (NSG) exists  ########################

##### Verify the existence of the Network Security Group

# Building Header
$Headers = @{}
$Headers.Add("Authorization","$($token.token_type) "+ " " + "$($token.access_token)")

# Network Security Groups - List All
# https://docs.microsoft.com/en-us/rest/api/virtualnetwork/networksecuritygroups/listall
# GET https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.Network/networkSecurityGroups?api-version=2020-05-01
$URL = "https://management.azure.com/subscriptions/$SubscriptionId/providers/Microsoft.Network/networkSecurityGroups?api-version=$ApiVersion"
$NSGList = Invoke-RestMethod -Method Get -Uri $URL -Headers $Headers 
# $NSGList.value.name contains the NSG name

#Sentinel for verification
$Sentinel = 0

    foreach ($item in 0..($NSGList.value.Length))
    {
          if ($NetworkSecurityGroupName -eq  ($NSGList.value[$item].name))
          {
                $Sentinel = 1
                break 
          }
    }

    if ($Sentinel -eq 1)
    {
       $ReturnCode = 0
       echo "Step 2: Done : The $NetworkSecurityGroupName NSG exists. ReturnCode: $ReturnCode"
     
    }
    else
    {
       $ReturnCode =2
       $ReturnMessage = "Step 2: Failed : The $NetworkSecurityGroupName NSG does not exists. ReturnCode $ReturnCode" 
       $ReturnMessage
       exit   
    }


########################################################################################################## 
###################### STEP3 Check if requested port already exists for the target  ######################

# Getting Azure Resource Groups corresponding to The NSG Name

$ResourceGroupName = ($NSGList.value[$item].id).Split("/")[4]

## Get the Security rules list
# https://docs.microsoft.com/en-us/rest/api/virtualnetwork/securityrules/list
# GET https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkSecurityGroups/{networkSecurityGroupName}/securityRules?api-version=2020-05-01
$URL = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/networkSecurityGroups/$NetworkSecurityGroupName/securityRules?api-version=$ApiVersion"
$RuleList = Invoke-RestMethod -Method Get -Uri $URL -Headers $Headers

#Sentinel for verification
$Sentinel = 0

    foreach ($item in 0..($RuleList.value.Length))
    {
          if ($PortNumber -eq  ($RuleList.value[$item].properties.destinationPortRange))
          {
                $Sentinel = 1
                break 
          }
    }

    if ($Sentinel -ne 1)
    {
       $ReturnCode = 0
       echo "Step 3: Done : The Port $PortNumber does not exist in the $NetworkSecurityGroupName NSG Rules. ReturnCode: $ReturnCode"
     
    }
    else
    {
       $ReturnCode =2
       $ReturnMessage = "Step 3: Failed : The Port $PortNumber already exists in the $NetworkSecurityGroupName NSG Rules. ReturnCode: $ReturnCode" 
       $ReturnMessage
       exit   
    }


########################################################################################################## 
################ STEP4 Initiate port opening command for requested destination address  ##################

# Here we are going to verify if the public $DestinationAddress is associated with a Network Interface

$NetworkInterfaceName = ($NSGList.value[0].properties.networkInterfaces[0].id).Split("/")[8]
# Network Interfaces - Get
# GET https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkInterfaces/{networkInterfaceName}?api-version=2020-05-01
# Source: https://docs.microsoft.com/en-us/rest/api/virtualnetwork/networkinterfaces/get
$URL = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/networkInterfaces/$($NetworkInterfaceName)?api-version=$ApiVersion"
$NetworkInterfaceInfo = Invoke-RestMethod -Method Get -Uri $URL -Headers $Headers

#Retrieving the public IP address Name
$PublicIpAddressName = ($NetworkInterfaceInfo.properties.ipConfigurations[0].properties.publicIPAddress[0].id).Split("/")[8]

# Retrieving the Public IP address behing the Public IP addess Name
# Public IP Addresses - Get
# GET https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/publicIPAddresses/{publicIpAddressName}?api-version=2020-05-01
# Source: https://docs.microsoft.com/en-us/rest/api/virtualnetwork/publicipaddresses/get
$URL = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/publicIPAddresses/$($PublicIpAddressName)?api-version=$ApiVersion"
$PublicIpAddressInfo = Invoke-RestMethod -Method Get -Uri $URL -Headers $Headers
$PublicIpAddress = $PublicIpAddressInfo.properties.ipAddress

    if ($PublicIpAddress -ne  $DestinationAddress)
    {
         $ReturnCode =2
         $ReturnMessage = "Step 4: Failed : There is no Network interface configured with the Public IP Address $DestinationAddress and associated with $NetworkSecurityGroupName NSG. ReturnCode: $ReturnCode" 
         $ReturnMessage
         exit
    }
    
# Verifying if a rule already use the $PriorityNumber    
#Sentinel for verification
$Sentinel = 0

    foreach ($item in 0..($RuleList.value.Length))
    {
          if ($PriorityNumber -eq  ($RuleList.value[$item].properties.priority))
          {
                $Sentinel = 1
                break 
          }
    }


    if ($Sentinel -eq 1){

         $ReturnCode =2
         $ReturnMessage = "Step 4: Failed : The Rule $($RuleList.value[$item].name) already has the priority number $PriorityNumber. You have to choose a different priority number between 100 and 4096. ReturnCode: $ReturnCode" 
         $ReturnMessage
         exit
    }

    else
    {
          # Initiate port opening command for requested destination address
          # Security Rules - Create Or Update
          # PUT https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkSecurityGroups/{networkSecurityGroupName}/securityRules/{securityRuleName}?api-version=2020-05-01
          # Source: https://docs.microsoft.com/en-us/rest/api/virtualnetwork/securityrules/createorupdate
          $SecurityRuleName = "Port_$PortNumber"
          $URL = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/networkSecurityGroups/$NetworkSecurityGroupName/securityRules/$($SecurityRuleName)?api-version=$ApiVersion"
      
          # Building body
          # HashTable format and invoke-restmethod-rest-api
          # Source: https://stackoverflow.com/questions/43051357/invoke-restmethod-rest-api-put-method/43052205

           $data = @{
            properties = @{
            protocol = "$Protocol"
            sourceAddressPrefix = "*"
            destinationAddressPrefix = "*"
            access = "Allow"
            destinationPortRange = $PortNumber
            sourcePortRange = "*"
            priority = $PriorityNumber
            direction = "inbound"
                          }
                    }

        $Body =  $data | ConvertTo-Json;
          $params = @{
          ContentType = 'application/json'
          Headers = $Headers
          Body = $Body
          Method = 'Put'
          URI = $URL
                    }
      $SecurityRule = Invoke-RestMethod @params
      
      
      if ($SecurityRule.properties.destinationPortRange -eq $PortNumber)
      {
       $ReturnCode = 0
       echo "Step 4: Done : Configuration successful !!! Mail send to max.tchana@autowit.co. ReturnCode: $ReturnCode"
        
        #$From ="max.tchana@students.williscollege.com"
        $From ="max.tchana@autowit.co"
        $To = "max.tchana@autowit.co"                                            
        $Subject = "Firewall White listing.Port $PortNumber"
        $Body =  "A new firewall rule has been created for the port $PortNumber in the Azure $NetworkSecurityGroupName NSG "
        #$SMTPServer = "outlook.office365.com"
        $SMTPServer = "smtp.zoho.com"
        $SMTPPort = "587"
        
        #Building credential for sending email
        $Password = Get-Content 'C:\mysecurestringforSOP3.txt' | ConvertTo-SecureString
        #Storing credential in a variable
        $Creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $From, $Password
                                   
        Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Credential $Creds -Port $SMTPPort -UseSsl 
        
         
        
      }
      else
      {
         $ReturnCode =2
         $ReturnMessage = "Step 4: Failed : unable to open requested  firewall Port. ReturnCode: $ReturnCode" 
         $ReturnMessage   
      }
      
         
    }
