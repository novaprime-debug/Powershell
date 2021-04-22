##############################################################################################################################
# Author :- Deepak Gautam 
# Email :- deepak.gautam@hpe.com
# Date :- 22-April-2021
#############################################################################################################################

#Variables

$computername=$env:COMPUTERNAME # Auto fetch old computer name
$ErrorActionPreference = 'silentlycontinue'


# Main
Write-Host "Welcome to the Computer Rename Command line utility." -ForegroundColor "Green"

Write-host "`nPlease provide the admin credentials to rename the computer. for e.g. domain\username" -ForegroundColor "Green"

$Credential = Get-Credential # Enter Credentials

Write-Host "Current computer name is $computername." -ForegroundColor "Blue"

$NewComputerName = read-host 'Enter the New Computer Name' # Enter new computer name

Rename-Computer -ComputerName "$computername" -NewName "$NewComputerName" -DomainCredential $Credential -Force -Restart # Rename the host

$result=$? # Getting the output of the last command

If($result -eq $true)
{
    Write-Host "Computer successfully renamed to $NewComputerName, please wait until system reboots." -ForegroundColor "Green"
}
else {
    Write-host "$Error[0].exception.message" -ForegroundColor "red"
}

