# -------------------------------------------------------------------------------
# 
#  File    : main.ps1
# 
# -------------------------------------------------------------------------------

function Sort-Naturally
{
    PARAM(
        [string[]]$strArray
    )

Add-Type -TypeDefinition @'
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace NaturalSort {
    public static class NaturalSort
    {
        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode)]
        public static extern int StrCmpLogicalW(string psz1, string psz2);

        public static System.Collections.ArrayList Sort(System.Collections.ArrayList foo)
        {
            foo.Sort(new NaturalStringComparer());
            return foo;
        }
    }

    public class NaturalStringComparer : IComparer
    {
        public int Compare(object x, object y)
        {
            return NaturalSort.StrCmpLogicalW(x.ToString(), y.ToString());
        }
    }
}
'@

    return [NaturalSort.NaturalSort]::Sort($strArray)
}

################################################ 
#Reading content of HOST1.txt, then splitting HOST1.txt to n files with name in format NXX*.txt. Each file contains name of  failing services #seperated by spaces for the day when research script was run NXX1.txt will be most recent log file.
################################################ 


$count = (get-content ".\HOST.txt" | select-string -pattern "##### Research start date").length

$a = $count

Get-Content ".\HOST1.txt" | ForEach-Object  {   

    If ($_ -match "##### Research start date")
    {
    $OutputFile = "NTMP$count.txt"
    $count--
    }  
    Add-Content $OutputFile $_
}

$files = Get-ChildItem NTMP*.txt 

foreach ($file in $files) 
{

$output =
foreach ($Line in $file)
{
    Get-Content $file | Where-Object { $_ -notmatch "^#"} | Where-Object { $_ -ne ""}
}
$output | Out-File $file

}

$sorted1 = Sort-Naturally -strArray @(Split-Path -Path "NTMP*.txt" -Leaf -Resolve)

################################################ 
#Reading contents of all files created with name NTMP*.txt and comparing content inside each file with NTMP1.txt as reference file.
################################################ 



$output1=
For ($i=2; $i -le $sorted1.count; $i++)

{
     
  New-Variable -Name "Files$i" -Value (Get-Content .\NTMP$i.txt)

  $tmp1 = Write-Output "-and ($"Files$i" -contains" '$Line'")"

  $strtmp1 =  [string]$tmp1

  $cmd1= $strtmp1.Replace(" ","")

  $tmp6 = (Get-Content .\NTMP$i.txt | Measure-Object –Line).Lines

  if ($tmp6 -le 1000)
  {
  "NTMP$i.txt" | Out-File filesnotcompared.txt -Append

  }
  else
  {
   write-Output $cmd1
  }
   
   
}

$output1 | Out-File "query.txt"



[string]$query1 = Get-Content .\query.txt
$query2 = $query1.TrimStart("-and")


$Files1 = Get-Content NTMP1.txt

$output2 =
ForEach ($Line in $Files1)
{
    
    If ( (Invoke-Expression $query2) -eq $true )
    {
       Write-output $Line
    }
}

$output2 | Out-File "sortedfinal.txt"



# Now this sortedfinal.txt file is converted to ldif file to remove the services in the LDAP. For that we use another script (Provided below).

# Working: -

# Sortedfinal.txt is consumed by the ldif script to convert it in the ldif file which can be run using Ldifde command to remove the services from LDAP.

# Command: -

# LDIFDE -i -s servername LdifFile.ldif


# Convert to LDIF



$sorted = Get-Content .\sortedfinal.txt


$output3=
foreach ($server in $sorted) 
{
$tmpstr5 = $server.Split('.')

$output1=
for ($i=1; $i -lt $tmpstr5.Count; $i++ )

{

$tmpstr1 = $server.Replace('.',',')

$vardc1= "DC="

$vardc2= "CN="

$tmpstr3 = $vardc1 + $tmpstr5[$i] + ','

$tmpstr4 = $vardc2 + $tmpstr5[0]


Write-Output $tmpstr3 

}

$tmppath1 = [string]$output1
$tmppath2 = $tmppath1.Replace(" ","")
$tmpfinal = $tmppath2.TrimEnd(",")

$oracletmp = ",CN=OracleContext,"

$finaldn = $tmpstr4+$oracletmp+$tmpfinal

$ldiftmp1 = "dn: $finaldn"
$ldiftmp2 = "changetype: delete"

Write-Output  $ldiftmp1 $ldiftmp2 `r

}

$output3 | Out-File tmpldif.ldif



