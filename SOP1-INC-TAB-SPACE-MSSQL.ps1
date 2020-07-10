    param(
        [Parameter(Mandatory)][string]$DataBaseName,[Parameter(Mandatory)][int]$NewSizeMB,[Parameter(Mandatory)][string]$FileName,
        [Parameter(Mandatory)][string]$DataBaseServer,[Parameter(Mandatory)][string]$DataBaseInstance
        )

#########################################################################################################
##################################### CREDENTIALS AND PATH DEFINITION ###################################
#User on the remote server
$RemoteUser = "remote"
#Password of the User on the remote remote server
$RemotePassword = Get-Content 'C:\mysecurestring.txt' | ConvertTo-SecureString
#Storing Remote User credential in a variable
$Creds1 = New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $RemoteUser, $RemotePassword

#Database User/login
$UserName = "testuser"
#Database User password
$Password = Get-Content 'C:\mysecurestring.txt' | ConvertTo-SecureString
#Storing database User credential in a variable
$Creds2 = New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $UserName, $Password
#Converting password into plaintext
$Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
#MSSQL DATA Path, Database file location
$MssqlPath = "C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA"

#SQL Server IP address or hostname
$TargetServer = $DataBaseServer

######################################################################################################## 
############### STEP1 Checking the Database connectivity to the target server  #########################

#Using the Invoke-Command with the stored credentials
Invoke-Command -ComputerName $TargetServer -Credential $Creds1 -ScriptBlock {
    param($DataBaseName, $NewSizeMB, $FileName, $DataBaseInstance, $Creds2, $UserName, $Password, $MssqlPath)

    #checking for instance name
    $Value = Get-SqlInstance -Credential $Creds2 -ServerInstance $DataBaseInstance

    if ($value.name -eq $DataBaseInstance -and $value.name -ne $NULL)
    {
      $ReturnCode = 0
      echo "Step 1: Done : The SQL Server Instance exists. ReturnCode: $ReturnCode" 

    }
    else
    {
       $ReturnCode =2
       $ReturnMessage = "Step 1: Failed : Database Instance does not exist. Unable to connect to the Database. ReturnCode $ReturnCode" 
       $ReturnMessage
       exit
    }

########################################################################################################
############### STEP2 Check if Database with the specified name exists on the server  ##################

Function Test-SQLConnection
    {    
        [OutputType([bool])]
        Param
        (
            [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]$ConnectionString
        )
        try
        {
            $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString;
            $sqlConnection.Open();
            $sqlConnection.Close();
            return $true;
        }
        catch
        {
            return $false;
        }
    }

    #Performing the Test Connection
    $value=Test-SQLConnection "Data Source=$DatabaseInstance;database=$DatabaseName;User ID=$UserName;Password=$Password;"

    if ($value -eq "True")
    {
       $ReturnCode = 0
       echo "Step 2: Done : $DatabaseName database exists. ReturnCode: $ReturnCode" 
          
    }
    else
    {
       $ReturnCode =2
       $ReturnMessage = "Step 2: Failed : Database with specified name not found on Server. ReturnCode: $ReturnCode" 
       $ReturnMessage
       exit
       
    }
    <#
    SQL Fixes Error - Login Error No process is on the other end of the pipe
    https://www.youtube.com/watch?v=J3ERo-M0BA4
    How To Quickly Test a SQL Connection with PowerShell
    https://mcpmag.com/articles/2018/12/10/test-sql-connection-with-powershell.aspx
    This script only work with SQL authentication. 
    If your database is set up with Windows authentication, this code will not work.
    #>

########################################################################################################
############################### STEP3 Check Current Size < New Size  ###################################
 
    #in case of permission denied error, $Value.length will be equal to 0
    $value = Get-ChildItem $MssqlPath | Where-Object Name -eq ($FileName + ".mdf")
    
    #Looking for the database File 
    if ((($value.Length)/1MB) -lt ($NewSizeMB) -and ($value.Length) -ne 0)
    {
       $ReturnCode = 0 
       echo "Step 3: Done : Target size greater than the current size. ReturnCode: $ReturnCode"
           
    }
    else
    {  
       $ReturnCode =2
       $ReturnMessage = “Step 3: Failed: New size cannot be less than existing Size, or the File does not exist, or access denied. ReturnCode: $ReturnCode" 
       $ReturnMessage
       exit
    }

########################################################################################################
############################### STEP4 Increase File Size  ##############################################

    #Implementing SQL statements to increase Database file size
        Invoke-Sqlcmd -ServerInstance $DataBaseInstance -Username $UserName -Password $Password -Query "
        USE master;
        GO
        ALTER DATABASE $DataBaseName
        MODIFY FILE
            (NAME = $FileName,
            SIZE = $NewSizeMB);
        GO"


   #Checking the new size of the database file

   #in case of permission denied error, $Value.length will be equal to 0
    $value = Get-ChildItem $MssqlPath | Where-Object Name -eq ($FileName + ".mdf")

   if ((($value.Length)/1MB) -ge ($NewSizeMB) -and ($value.Length) -ne 0)
   {
          $ReturnCode =1 
          echo "Step 4: Success !!!! ReturnCode: $ReturnCode"
    }
    else
    {  
       $ReturnCode =2
       $ReturnMessage = “Step 4: Failed: Error expanding the size of Database. ReturnCode: $ReturnCode`n $Error[0]" 
       $ReturnMessage
       exit
    }

} -ArgumentList $DataBaseName, $NewSizeMB, $FileName, $DataBaseInstance, $Creds2,$UserName, $Password, $MssqlPath