#This script allows to install an .exe file to remote server ('168.62.58.22')

Param(
[Parameter(Mandatory)][string]$PackageURL, [Parameter(Mandatory)][string][ValidateSet("Silent","Interactive")]$ArgumentList, 
[Parameter(Mandatory)][string]$TargetServer)

#########################################################################################################
##################################### CREDENTIALS AND PATH DEFINITION ###################################
#User on the remote server
$RemoteUser = "remote"
#Password of the User on the remote remote server
$RemotePassword = Get-Content 'C:\mysecurestring.txt' | ConvertTo-SecureString
#Storing Remote User credential in a variable
$Creds1 = New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $RemoteUser, $RemotePassword

#$PackageURL = 'https://github.com/Max-TCHANA/AWIT-Coop-Activities'



#Using the Invoke-Command with the stored credentials
Invoke-Command -ComputerName $TargetServer -Credential $Creds1 -ScriptBlock {
    param($PackageURL,$ArgumentList)

    #Getting a substring of the $PackageURL by removing the "https://github.com" part
    $Repo = $PackageURL.Remove(0,18)
    #Fixing the security require 
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    # Fetching the github repository HTML page Data
    $Page = Invoke-WebRequest -Uri $PackageURL -UseBasicParsing

    #Storing the content of the HTML source code of the repository into a text file
    $page.RawContent | Out-File "C:\Windows\Temp\file.txt"


    ######################################################################################################## 
    ############### STEP1 Check if .exe present on the github repository  ##################################

    [string]$value = Get-content "C:\Windows\Temp\file.txt" | Select-String -Pattern "$Repo/blob/master/" | Select-String -Pattern ".exe</a>"

    echo "   "
    
        if ($value -ne $null)
        {
           $ReturnCode = 0
           echo "Step 1: Done : A .exe file exists in the $PackageURL github repository. ReturnCode: $ReturnCode"
        }
        else
        {
            $ReturnCode =2
            $ReturnMessage = "Step 1: Failed : No .exe file exists in the $PackageURL github repository. ReturnCode $ReturnCode" 
            $ReturnMessage
            exit
    
        }

     
    #Text treatment to built the full exe URL to download it
    [string]$value = $value.split(" ") | Select-String -Pattern ".exe</a>"
    [string]$value = $value.split(">") | Select-String -Pattern ".exe`""
    [string]$value = $value.split("`"") | Select-String -Pattern ".exe"
    [string]$value = $PackageURL.substring(0,18) + $value
    [string]$ExeURL = $value.replace("blob","raw")
    
    
    
    ######################################################################################################## 
    ############### STEP2 Download the installation file to the target server  #############################

    #A common .NET class used for downloading files is the System.Net.WebClient class.https://blog.jourdant.me/post/3-ways-to-download-files-with-powershell
    $WebClient = New-Object System.Net.WebClient
    #Retrieving the exe file name from the $ExeURL 
    $FileName = $ExeURL.split("/")|Select-String -Pattern "exe"
    #Destination of the file that we are going to download
    $Output = "C:\Users\remote\Downloads\$FileName"
    $WebClient.DownloadFile($ExeURL, $output)

    #Verify the success of the download

    [string]$verify = dir $Output

        
        if ($verify -ne $null)
        {
           $ReturnCode = 0
           echo "Step 2: Done : The $FileName file has been dowmloaded. ReturnCode: $ReturnCode"
        }
        else
        {
            $ReturnCode =2
            $ReturnMessage = "Step 2: Failed : Not Able to download the file on the target host. ReturnCode $ReturnCode" 
            $ReturnMessage
            exit
    
        }

    ######################################################################################################## 
    ########################## STEP3 Check if software already installed  ##################################
    
    # A function Get-Software allows to retrieve the list of all the installed software on multiple computers (locally and remotely)
    # https://mcpmag.com/articles/2017/07/27/gathering-installed-software-using-powershell.aspx
    # Here is a simple link to get installed software list locally
    # https://www.howtogeek.com/165293/how-to-get-a-list-of-software-installed-on-your-pc-with-a-single-command/

    #Storing the list of installed softwares in a .txt file
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |`
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize `
    > "C:\Windows\Temp\Installed.txt"
        
    #Retrieving the content of the file
    [string]$InstallSoftware = cat "C:\Windows\Temp\Installed.txt"

    #Getting the file object
    $File = dir "C:\Users\remote\Downloads\$FileName"
    #Getting the Software name ProductName property of the VersionInfo property
    [string]$Product = $File.VersionInfo.ProductName
    #Verifying the existence of the Software in the list of installed softwares
    $Checker = $InstallSoftware.Contains($Product)

    # Performing verification
    if ($Checker -eq $false)
    {
        $ReturnCode = 0
        echo "Step 3: Done : The $Product Software is not yet installed on the target host. ReturnCode: $ReturnCode"
            
    }
    else
    {
     $ReturnCode =2
     $ReturnMessage = "Step 3: Failed : The $Product Software is already installed on the target host. ReturnCode: $ReturnCode" 
     $ReturnMessage
     exit         
    }

    ######################################################################################################## 
    ########## STEP4 Install  the package using the defined arguments. Test if software installed ##########

    switch ($ArgumentList)
    {
        #installation in silent mode
        'Silent' {Start-Process -Wait -FilePath "C:\Users\remote\Downloads\$FileName" -ArgumentList "/S"}
        #'Silent' {powershell.exe "C:\Users\remote\Downloads\$FileName" /sAll /msi /norestart ALLUSERS=1 EULA_ACCEPT=YES}
        
        #installation in interactive mode
        'Interactive' {Start-Process -Wait -FilePath "C:\Users\remote\Downloads\$FileName" }
      
    }

    #Storing the list of installed softwares in a .txt file
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |`
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize `
    > "C:\Windows\Temp\Installed.txt"
        
    #Retrieving the content of the file
    [string]$InstallSoftware = cat "C:\Windows\Temp\Installed.txt"
    #Verifying the existence of the Software in the list of installed softwares
    $Checker = $InstallSoftware.Contains($Product)

    # Performing verification
    if ($Checker -eq $True)
    {
        $ReturnCode = 0
        echo "Step 4: Done : The $Product Software has been installed on the target host. ReturnCode: $ReturnCode"
            
    }
    else
    {
     $ReturnCode =2
     $ReturnMessage = "Step 4: Failed : Installation of the $Product software failed. ReturnCode: $ReturnCode" 
     $ReturnMessage
     exit         
    }

} -ArgumentList $PackageURL,$ArgumentList

