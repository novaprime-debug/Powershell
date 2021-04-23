##############################################################################################################################
# Author :- Deepak Gautam 
# Email :- deepakgautam139@gmail.com
# Date :- 22-April-2021
# Description :- Script is to get enabled servers and clients and attach the output to the email for automation. You would have to 
#                create a scheduled task to run the script. 
#############################################################################################################################

# Import Module Psexcel which enables converting csv files to excel files or you can use install-module if PS Version is 5 or above.

Import-Module "C:\Program Files\WindowsPowerShell\Modules\PSExcel\1.0.2\PSExcel.psm1"

# Install-Module -Name psexcel -SkipPublisherCheck

# Import-module Powershell Archive which enables compressing the files (already exist in PS Version is 5 or above)

Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.PowerShell.Archive\1.2.5\Microsoft.PowerShell.Archive.psm1"


# variables

$ErrorActionPreference="silentlycontinue"
$date=(Get-Date).GetDateTimeFormats()[6]
$server="servers_$date"
$client="clients_$date"
$report="AD_Dump_$date"
$scriptpath="C:\script"
$EmailBody = "Please find the attached AD Dump for $date.`n`nRegards `nDeepak Gautam"
$EmailFrom = "deepakgautam139@gmail.com"
[string[]]$EmailTo = "EmailID1","EMailID2"
[string[]]$EmailCC = "EMailid3","EMailID4"
$EmailSubject = "$report"
$SMTPServer = "smtp.office365.com"

# To generate a AES key for encryption (Need to be used only once,must be removed from the script)
$aeskeypath = "$scriptpath\aeskey.key"
$AESKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
Set-Content $aeskeypath $AESKey 

# Retrieve all windows Server computer

Get-ADComputer -Filter 'operatingsystem -like "*server*" -and enabled -eq "true"' -Properties Name, canonicalName, Enabled, DNSHostName, IPv4Address, LastlogonDate, Passwordlastset, Operatingsystem, Whenchanged | Sort-Object -Property Operatingsystem | Select-Object -Property Name, canonicalName, Enabled, DNSHostName, IPv4Address, LastlogonDate, Passwordlastset, Operatingsystem, Whenchanged | export-csv -path $scriptpath\test.csv
$import=Get-Content -Path $scriptpath\test.csv
$import | Select-Object -Skip 1 | Set-Content $scriptpath\servers.csv
Import-Csv $scriptpath\servers.csv | Export-XLSX $scriptpath\$server.xlsx
Remove-Item -Path $scriptpath\test.csv,$scriptpath\servers.csv -ErrorAction SilentlyContinue


# Retrieve all windows client computer

Get-ADComputer -Filter 'operatingsystem -notlike "*server*" -and enabled -eq "true"' -Properties Name, canonicalName, Enabled, DNSHostName, IPv4Address, LastlogonDate, Passwordlastset, Operatingsystem, Whenchanged | Sort-Object -Property Operatingsystem | Select-Object -Property Name, canonicalName, Enabled, DNSHostName, IPv4Address, LastlogonDate, Passwordlastset, Operatingsystem, Whenchanged | export-csv -path $scriptpath\test1.csv
$import=Get-Content -Path $scriptpath\test1.csv
$import | Select-Object -Skip 1 | Set-Content $scriptpath\clients.csv
Import-Csv $scriptpath\clients.csv | Export-XLSX $scriptpath\$client.xlsx
Remove-Item -Path $scriptpath\test1.csv,C:\script\clients.csv -ErrorAction SilentlyContinue


# To write password into a password file using a secure AES key (Need to be used only once,must be removed from the script)

(get-credential).password | ConvertFrom-SecureString -Key (Get-Content $scriptpath\aeskey.key) | set-content $scriptpath\password.txt

# Using the encrypted password again in the script

$encrypted=Get-Content $scriptpath\password.txt | ConvertTo-SecureString -Key (Get-Content $scriptpath\aeskey.key)

# Using the saved password and username in the credential

$credential = New-Object System.Management.Automation.PSCredential($EmailFrom,$encrypted)

# Compress two files in a zip

Compress-Archive -Path "$scriptpath\$client.xlsx","$scriptpath\$server.xlsx" -DestinationPath "$scriptpath\$report.zip"

# Sending Email using Send-MailMessage with attachments

Send-MailMessage -From $EmailFrom -To $EmailTo -Cc $EmailCC -Subject $EmailSubject -body $EmailBody -SmtpServer $SMTPServer  -Credential $credential -UseSsl -Attachments $scriptpath\$report.zip -DeliveryNotificationOption OnFailure

# Removing the unwanted files

Remove-Item -Path $scriptpath\$server.xlsx, $scriptpath\$client.xlsx -ErrorAction SilentlyContinue







