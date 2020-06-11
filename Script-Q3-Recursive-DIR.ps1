#This scrip List names of all ".exe" files in your C:\ Drive by recursively looping into all sub folders.

Get-ChildItem  C:\ -File -Recurse | Where-Object {$_.Name -like "*.exe"} | Select-Object -Property Name