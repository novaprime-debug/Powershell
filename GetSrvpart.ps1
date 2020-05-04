#------------------------------------------------------------------------------
# (C) novaprime-debug/Powershell
#------------------------------------------------------------------------------
# Content:  This script segregates the Service Name and Partition Name into a seperate file from TNSNAMES.ORA.
# TNSNAMES.ORA is used in ORACLE NAME SERVICE for Name Resolution.
#
# Author:   NOVA PRIME
# 
# Date: 5 April 2020
#
#------------------------------------------------------------------------------
# Note: As this is the Version 1 of the script , no logging or error handling is done. Please request the same.
#------------------------------------------------------------------------------

#@Main

# Functions
Function GetSrvPart
{

# Path for TNSNAMES.TXT( Conver *.ora to *.txt)
$Filecontent=Get-Content -Path C:\Users\nova\Downloads\tnsnames.txt
# Measuring the no. of lines in TNSNAMES.TXT
$lines= $Filecontent | Measure-Object -Line

# Declaring Arrays

$filesfinal=New-Object string[] $lines.Lines
$ServiceName=New-Object string[] $lines.Lines
$PartitionName=New-Object string[] $lines.Lines

# Loop

$i=0
Do {
$filesfinal[$i]=$Filecontent[$i].Substring(0,$Filecontent[$i].indexof('='))
$ServiceName[$i]=$filesfinal[$i].Substring(0,$filesfinal[$i].indexof('.'))
$PartitionName[$i]=$filesfinal[$i].Substring($filesfinal[$i].IndexOf('.')+1,$filesfinal[$i].length-$filesfinal[$i].IndexOf('.')-1)
$i++



} while($i -lt $lines.Lines)

$ServiceNamefinal=$ServiceName | Select-Object @{Name='ServiceName';Expression={$_}}

# Service Name File only

$ServiceNamefinal | Export-Csv c:\users\z003ztcf\ServiceName.csv -NoTypeInformation
$PartitionNamefinal=$PartitionName | Select-Object @{Name='PartitionName';Expression={$_}}

# Partition Name File only
$PartitionNamefinal | Export-Csv c:\users\z003ztcf\PartitionName.csv -NoTypeInformation 
    
}

# Final File 

for ( $n = 0; $n -lt $servicenamefinal.Count; $n++ ) {
    [PSCustomObject]@{  
     ServiceName = $ServiceNamefinal[$n].ServiceName
     PartitionName = $PartitionNamefinal[$n].Partitionname } | Export-Csv C:\users\nova\Downloads\final.csv -NoTypeInformation -Append
       
  
} 




