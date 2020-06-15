<# https://www.itprotoday.com/powershell/write-output-or-write-host-powershell

** If you possibly want to write data to the screen, but also want the data to be passed down the pipeline to further commands, then use Write-Output. 
** If you only want data to display to the screen, use Write-Host. Write-Host does not allow the data to be passed down the pipeline to further commands.


#>

function Receive-Output 
{
    process { Write-Host $_ -ForegroundColor Green }
}

Write-Output "this is a test" | Receive-Output
Write-Host "this is a test" | Receive-Output
Write-Output "this is a test"

Write-Host "You are looking " -NoNewline
Write-Host "AWESOME" -ForegroundColor Red -BackgroundColor Yellow -NoNewline
Write-Host " today"