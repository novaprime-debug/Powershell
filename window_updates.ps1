##############################################################################################################################
# Author :- Deepak Gautam 
# Email :- deepakgautam139@gmail.com
# Date :- 22-April-2021
# Description :- Script is to get windows updates for a certain timeline from selected servers
#############################################################################################################################

# variables

$servers=Get-Content -Path C:\script\server.txt # Get list of servers

# Apply loop to get the windows updates for selected servers

foreach($item in $servers)
{
# Command to get windows updates from 231 days till now
get-wmiobject -class win32_quickfixengineering -ComputerName $item | Where-Object {$_.installedon -gt ((get-date).AddDays(-231))} | Select-Object -Property pscomputername,hotfixid,installedon | Sort-Object -Property pscomputername,installedon -ErrorAction SilentlyContinue | Export-Csv -Append  C:\script\final-final.csv

$ran=$? # Getting the output of last command

if($ran -eq $true)
{
Write-Host "data retrieval from $item server sucessfull" #sucessfull 
}
else{Write-Host "Data Retrival from $item server failed" #failed
}
}

