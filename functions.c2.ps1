﻿ function get-C2LinkedLocationName{
 <#
   .SYNOPSIS
   search Location name from C2(DB collect data assets from active network switches)
   Work for NK and Printers Name
   .PARAMETER Name
   ITSM:ConfigItem Name
   .EXAMPLE
   get-get-C2LinkedLocationName 'PRN 1227_HP_M1212'
   get-get-C2LinkedLocationName 4104
  .LINK
  https://github/daniloveb/otrs_ps
   #>
    [CmdletBinding()]
     param (
       [Parameter( Mandatory = $true )] [string] $Name
    )
 
    . "$PSScriptRoot\Set-GlobalVars.ps1"

 [string]$DatabaseName = 'C2'
 
 [string]$connString = 'Server=' + $SQLServerName + ';Database=' + $DatabaseName + ';Persist Security Info=False;Integrated Security=SSPI'
 [string]$SQLCommand = "select [Korp]+ '-' + [Komn] Komn from [C2].[dbo].Geo as GEO
 right join 
 (select ID_Geo from [C2].[dbo].SCS as SCS
   right join
   (SELECT [ID]
       ,[Name]
       ,[Type]
   FROM [C2].[dbo].[v_MACs_forLookup] where [Name] like '${Name}: *') Macs
   on SCS.ID_vMACs = Macs.ID) SCS_GEO_ID
   on GEO.ID = SCS_GEO_ID.ID_Geo"
 
    $conn = New-Object System.Data.SqlClient.SqlConnection($connString)
     $conn.Open()
 
    $cmd = New-Object System.Data.SqlClient.SqlCommand($SQLCommand, $conn)
 $geo_name = $cmd.ExecuteScalar()
 return $geo_name
 }
