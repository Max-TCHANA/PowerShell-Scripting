<<<<<<< HEAD
﻿#Read and write Excel spreadsheets with the ImportExcel PowerShell module
#https://4sysops.com/archives/read-and-write-excel-spreadsheets-with-the-importexcel-powershell-module/
#Install-Module -Name ImportExcel

$FilePath = "C:\Users\mjtch\Desktop\TicketData (2)\TicketData\Analysis on incidents (Abbvie 2019) - Copy.xlsx"
$WorksheetName = "Analysis on incidents"
$ColumnName = "Original Summary"
$OutPutFile = "C:\Users\mjtch\Desktop\Output.csv"
$Text = Import-Excel -Path $FilePath -WorksheetName $WorksheetName | Select-Object -Property $ColumnName

$TimeElapse = Measure-Command { Write-Host "*** Start: $(Get-Date)"

$Tagging = foreach ($item in 0 ..(($Text.Length) - 1))
{
  #Retrieving the text to be tagged
  $Phrase =  ($Text[$item].Split("="))[1].split("}")[0]
  #Checking the output type after tagging
  $Type = ((Split-PartOfSpeech ($Text[$item].Split("="))[1].split("}")[0] -Raw).gettype() | select-object -Property Name).name

  
  if ($Type -eq "String")
  {
     Split-PartOfSpeech ($Text[$item].Split("="))[1].split("}")[0] -Raw 
  }
  else
  {
    $OutPutLength = (Split-PartOfSpeech $Phrase -Raw).length
    $Line = (Split-PartOfSpeech $Phrase -Raw)[0]
    
    Foreach ($item in 1 ..($OutPutLength-1)){
    $Next = (Split-PartOfSpeech $Phrase -Raw)[$item]
    $Line = $Line + " $Next"    
    
   }
   #Printing the result in 1 row 
   $Line   
  }

}

#Creating the CSV file containing the tagged text
echo $Tagging | Out-File $OutPutFile

}

echo "Time Elapsed : $TimeElapse"
=======
﻿#Read and write Excel spreadsheets with the ImportExcel PowerShell module
#https://4sysops.com/archives/read-and-write-excel-spreadsheets-with-the-importexcel-powershell-module/
#Install-Module -Name ImportExcel

$FilePath = "C:\Users\mjtch\Desktop\TicketData (2)\TicketData\Analysis on incidents (Abbvie 2019) - Copy.xlsx"
$WorksheetName = "Analysis on incidents"
$ColumnName = "Original Summary"
$OutPutFile = "C:\Users\mjtch\Desktop\Output.csv"
$Text = Import-Excel -Path $FilePath -WorksheetName $WorksheetName | Select-Object -Property $ColumnName

$TimeElapse = Measure-Command { Write-Host "*** Start: $(Get-Date)"

$Tagging = foreach ($item in 0 ..(($Text.Length) - 1))
{
  #Retrieving the text to be tagged
  $Phrase =  ($Text[$item].Split("="))[1].split("}")[0]
  #Checking the output type after tagging
  $Type = ((Split-PartOfSpeech ($Text[$item].Split("="))[1].split("}")[0] -Raw).gettype() | select-object -Property Name).name

  
  if ($Type -eq "String")
  {
     Split-PartOfSpeech ($Text[$item].Split("="))[1].split("}")[0] -Raw 
  }
  else
  {
    $OutPutLength = (Split-PartOfSpeech $Phrase -Raw).length
    $Line = (Split-PartOfSpeech $Phrase -Raw)[0]
    
    Foreach ($item in 1 ..($OutPutLength-1)){
    $Next = (Split-PartOfSpeech $Phrase -Raw)[$item]
    $Line = $Line + " $Next"    
    
   }
   #Printing the result in 1 row 
   $Line   
  }

}

#Creating the CSV file containing the tagged text
echo $Tagging | Out-File $OutPutFile

}

echo "Time Elapsed : $TimeElapse"
>>>>>>> 5eff8346c1d65530863651080c57c020f1cb5406
echo "*** End: $(Get-Date)"