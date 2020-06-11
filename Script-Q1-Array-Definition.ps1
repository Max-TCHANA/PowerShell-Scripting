<# 
This scrip defines PowerShell arrays of the following types -
- Integer
- JSON
- String
- array
- Hash Table
- Datetime
- Secure String(Also Mention the Type of encryption used)

#>

# Array of type Integer
[int[]] $MyArrayofInteger = 0,1,2,3,4,5,6

# Array of type String'
[String[]] $MyArrayofString = 'root','cafe',"abc",'3','4','5',"End"

# Array of type String'
[Datetime[]] $MyArrayofDatetime = Get-Date

# Array of arrays
# https://devblogs.microsoft.com/scripting/easily-create-and-manipulate-an-array-of-arrays-in-powershell/
$MyArrayofArrays = $MyIntegerArray,$MyStringArray, $MyDatetimeArray

# Create a new hash table with key-value pairs
$list1 = @{Name = "PC01"; IP="10.20.10.11"; User="Jimmy Nkouimi"}
# Create another hash table with key-value pairs
$list2 = @{Name = "PC02"; IP="10.20.10.12"; User="Max Tchana"}

# Array of hash Tables
$MyArrayofHashTable = $list1, $list2


#Building an Array of SecureString
#Converting simple string into securetring
$MyArrayofSecureString = 'a','a','a','a','a','a','a'
$i=0
foreach ($i in 0..6){ $MyArrayofSecureString[$i] = ConvertTo-SecureString $MyArrayofString[$i] -AsPlainText -Force}
# You can use ConvertFrom-SecureString for Ecription of securestring. It uses AES Encryption 192-bit key to encrypt a securestring.

#Converting from securestring to plaintext
$a =  [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($MyArrayofSecureString[6]))


#Building an Array of JSON object
# JavaScript Object Notation (JSON) format

$Content1 = @(
    @{
        FirstName='Max'
        LastName='Tchana'
    }
)
ConvertTo-Json -InputObject $Content1

$Content2 = @(
    @{
        FirstName='Jimmy'
        LastName='Nkouimi'
    }
)
ConvertTo-Json -InputObject $Content2

$MyArrayofJSON = $Content1,$Content2

#Some Tests
$MyArrayofJSON[0,1]
$MyArrayofJSON[1].Firstname
$Content1.FirstName

