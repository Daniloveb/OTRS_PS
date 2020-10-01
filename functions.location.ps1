
function create-location {
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [string] $Name,
		[Parameter( Mandatory = $true )] [string] $Type 
   )
   $UserLogin ="srv_otrs"
   $Password = "P@ssw0rd"
   $url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
   <soapenv:Body>
      <tic:Operation_CI_Create>
         <UserLogin>$UserLogin</UserLogin>
         <Password>$Password</Password>
      <ConfigItem>
                <Class>Location</Class>
                <Name>$Name</Name>
                <DeplState>В работе</DeplState>
                <InciState>Исправен</InciState>
                <CIXMLData><Type>$Type</Type></CIXMLData>
         </ConfigItem>
      </tic:Operation_CI_Create>
   </soapenv:Body>
</soapenv:Envelope>
"@


$enc_utf = [System.Text.Encoding]::UTF8
$Body = $enc_utf.GetBytes($XMLData)
#$Body = [byte[]][char[]]$XMLData
#Write-Host $Body

$Request = [System.Net.HttpWebRequest]::Create($url)
$Request.Headers.Add("SOAPAction", "http://www.otrs.org/Connector/Operation_CI_Create")
$Request.Method="POST"
$Request.Accept="text/xml"
$Request.ContentType="application/xml"
$Request.KeepAlive = $false
$Stream = $Request.GetRequestStream()
$Stream.Write($Body,0,$Body.Length)
$response = $Request.GetResponse()
$requestStream = $response.GetResponseStream()
$readStream = New-Object System.IO.StreamReader $requestStream
$data = $readStream.ReadToEnd()
#Write-Host data $data
$id = ([xml]$data).Envelope.Body.Operation_CI_CreateResponse.ConfigItemID
#Write-Host id $id
return $id
}

#search OTRS location id
function search-location_id-for_loc_name {
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [string] $Name
   )
   
   if ($Name -eq '' -or $Name -eq $null){
      Write-Host "Name is empty. Exit search"      
      return $null
   }

   $UserLogin ="srv_otrs"
   $Password = "P@ssw0rd"   
   $url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
   <soapenv:Body>
      <tic:Operation_CI_Search>
         <UserLogin>$UserLogin</UserLogin>
         <Password>$Password</Password>
      <ConfigItem>
                <Class>Location</Class>
                <Name>$Name</Name>
         </ConfigItem>
      </tic:Operation_CI_Search>
   </soapenv:Body>
</soapenv:Envelope>
"@


$enc_utf = [System.Text.Encoding]::UTF8
$Body = $enc_utf.GetBytes($XMLData)
#$Body = [byte[]][char[]]$XMLData
#Write-Host $Body

$Request = [System.Net.HttpWebRequest]::Create($url)
$Request.Headers.Add("SOAPAction", "http://www.otrs.org/Connector/Operation_CI_Search")
$Request.Method="POST"
$Request.Accept="text/xml"
$Request.ContentType="application/xml"
$Request.KeepAlive = $false
$Stream = $Request.GetRequestStream()
$Stream.Write($Body,0,$Body.Length)
$response = $Request.GetResponse()
$requestStream = $response.GetResponseStream()
$readStream = New-Object System.IO.StreamReader $requestStream
$data = $readStream.ReadToEnd()
#Write-Host data $data
$id = ([xml]$data).Envelope.Body.Operation_CI_SearchResponse.ConfigItemIDs
#Write-Host id $id
return  $id
}


#работает только для комплектов
#для принтеров и UPS префиксы отличаются во view v_MACs_forLookup  
function search-location_id-for_NK{
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [string] $NK
   )
   if ($NK -eq ''){
      Write-Host "NK is empty. Exit search"      
      return $null
   }
      $geo_name = search-location_name-for_NK $NK
   if ([string]::IsNullOrEmpty($geo_name))   {
      return $null   }
   else {
      return search-location_id-for_loc_name $geo_name   }
}

function search-location_id-for_PrinterName{
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [string] $Name
   )
   if ($NK -eq ''){
      Write-Host "NK is empty. Exit search"      
      return $null
   }
      $geo_name = search-location_name-for_PrinterName $Name
   if ([string]::IsNullOrEmpty($geo_name))   {
      return $null   }
   else {
      return search-location_id-for_loc_name $geo_name   }
}

function search-location_name-for_NK{
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [string] $NK
   )


[string]$DatabaseName = 'C2'
[string]$SQLServerName = 'vsql2016.novator.ru'

[string]$connString = 'Server=' + $SQLServerName + ';Database=' + $DatabaseName + ';Persist Security Info=False;Integrated Security=SSPI'
[string]$SQLCommand = "select [Korp]+ '-' + [Komn] Komn from [C2].[dbo].Geo as GEO
right join 
(select ID_Geo from [C2].[dbo].SCS as SCS
  right join
  (SELECT [ID]
      ,[Name]
      ,[Type]
  FROM [C2].[dbo].[v_MACs_forLookup] where [Name] like '${NK}: *') Macs
  on SCS.ID_vMACs = Macs.ID) SCS_GEO_ID
  on GEO.ID = SCS_GEO_ID.ID_Geo"

   $conn = New-Object System.Data.SqlClient.SqlConnection($connString)
	$conn.Open()

   $cmd = New-Object System.Data.SqlClient.SqlCommand($SQLCommand, $conn)
$geo_name = $cmd.ExecuteScalar()
return $geo_name
}

#PrinterName вида "PRN 2071_Ricoh_SP230"
function search-location_name-for_PrinterName{
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [string] $Name
   )


[string]$DatabaseName = 'C2'
[string]$SQLServerName = 'vsql2016.novator.ru'

[string]$connString = 'Server=' + $SQLServerName + ';Database=' + $DatabaseName + ';Persist Security Info=False;Integrated Security=SSPI'
[string]$SQLCommand = "select [Korp]+ '-' + [Komn] Komn from [C2].[dbo].Geo as GEO
right join 
(select ID_Geo from [C2].[dbo].SCS as SCS
  right join
  (SELECT [ID]
      ,[Name]
      ,[Type]
  FROM [C2].[dbo].[v_MACs_forLookup] where [Name] like '${Name}:%') Macs
  on SCS.ID_vMACs = Macs.ID) SCS_GEO_ID
  on GEO.ID = SCS_GEO_ID.ID_Geo"

   $conn = New-Object System.Data.SqlClient.SqlConnection($connString)
	$conn.Open()

   $cmd = New-Object System.Data.SqlClient.SqlCommand($SQLCommand, $conn)
$geo_name = $cmd.ExecuteScalar()
return $geo_name
}

#computer-Create -NK "1500" -Owner "Daniloveb"
#create-computer 1635 DanilovEB 'В работе' 'Исправен' 'Local' 'Десктоп'
#search-location Корпус98
#create-location 'Корпус 72' Здание
#search-location-forNK Computer 4104
#search-LocationName-forNK Computer 4104
#search-location_id-for_name 98-102
#search-location_name-for_PrinterName "PRN 2071_Ricoh_SP230"
#search-location_name-for_NK 4104