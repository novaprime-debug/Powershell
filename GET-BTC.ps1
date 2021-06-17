##############################################################################################################################
#   Author :- Deepak Gautam                                                                                                  #
#   Email :- deepakgautam139@gmail.com                                                                                       #
#   Date :- 17-June-2021                                                                                                     #
#   Description :- Script is to generate random hash with predefined zeroes.                                                 #
##############################################################################################################################

<# 
BTC mining is done using calculating Hash with predefined zeroes as suffix. 
Currently BTC hash that are being submitted have 20 zeros as suffix.
This script was done as a fun activity over a weekend to see if we can do this by powershell.

More information can be found on https://www.blockchain.com/explorer

Disclaimer:-  
It is not advised to increase the predefined zeros before hash from '0000' as it consumes a lot of 
resources. Powershell is not the right language to do this. I'm not liable if you run this and break your OS.
#>

# Function

function GET-BTC {
    [CmdletBinding()]
    param (
        [Parameter(Position=0,ValueFromPipeline = $true,Mandatory=$True)]
        [string]$filepath, # parameter for the file path of password file.
        [Parameter(Position=0,ValueFromPipeline = $true,Mandatory=$True)]
        [string]$zeroes # parameter for the predefined zeroes in the hash
    )
    
    begin {
     
        $loopcount=0 # variable to keep count of loops
        $stopwatch=[System.Diagnostics.Stopwatch]::StartNew() # A stop watch to calculate time taken to generate hash.
    }
    
    process {
        do {
            $Password = New-Object -TypeName PSObject
            $Password | Add-Member -MemberType ScriptProperty -Name "Password" -Value { ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | Sort-Object {Get-Random})[0..30] -join '' } # Generating Random Password 
            Out-File -InputObject $Password.Password -FilePath $filepath -Force # Writing the password into a text file
            Clear-Variable Password
            $hash=Get-FileHash -Path $filepath # Calculating hash of the password file 
            $loopcount++ # Increasing the loop count
            Write-Host On Loop $loopcount # Showing no. of loops script already ran.
        } until ($hash.hash.StartsWith("$zeroes")) # Condition to set predefined zeroes in the hash
    }
    
    end {
        $stopwatch.Stop() # stopping the stopwatch
        Write-host Calculated Hash : $hash.hash # showing generated hash
        write-host "No. of total Loop ran:$loopcount" # showing total no. of loops ran by the script to calculate the hash.
        Write-Host Time taken: $stopwatch.Elapsed.Minutes min # showing time taken in minutes.
    }
}

#Main

# remove # from the next line and provide the path for filepath and zeroes variable

#GET-BTC -filepath "D:\password.txt" -zeroes 00 
