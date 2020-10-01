
function create-computer {
   [CmdletBinding()]
	param (
		[Parameter( Mandatory = $true )] [int] $NK,#число
      [string] $Owner, #samAccountName!!!! логин
      [string] $State,#В работе,Настройка/Модернизация,Планирование,Ремонт,Склад,Списан,Тестирование
      [string] $Incident,
      [string] $Network,#Internet,Local,Other,КСПД,Секрет
      [string] $Type,#Десктоп,Другое,Ноубук,Планшет,Сервер,Телефон
      [string] $Description,
      [string] $Model,
      [string] $Secure
   )
   $UserLogin ="srv_otrs"
   $Password = "P@ssw0rd"

   $Description = $Description.Replace('<',' ').Replace('>','')
   $Model = $Model.Replace('<',' ').Replace('>','')

   Write-Host "functions.ci create-computer $Owner $State $Incident $Network $Type $Description $Model $Secure"

   switch (([string]$NK).Length) {
      1 { $Name = "ARM-000" + $NK }
      2 { $Name = "ARM-00" + $NK }
      3 { $Name = "ARM-0" + $NK }
      Default {$Name = "ARM-" + $NK}
   }
   $url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
     <soapenv:Body>
         <tic:Operation_CI_Create>
            <UserLogin>$UserLogin</UserLogin>
            <Password>$Password</Password>
            <ConfigItem>
                <Class>Computer</Class>
                <Name>$Name</Name>
                <DeplState>$State</DeplState>
                <InciState>$Incident</InciState>
                <CIXMLData><NK>$NK</NK><Owner>$Owner</Owner><Network>$Network</Network><Type>$Type</Type><Description>$Description</Description><Model>$Model</Model><Secure>$Secure</Secure></CIXMLData>
            </ConfigItem>
         </tic:Operation_CI_Create>
      </soapenv:Body>
</soapenv:Envelope>
"@


$enc_utf = [System.Text.Encoding]::UTF8
$Body = $enc_utf.GetBytes($XMLData)
#$Body = [byte[]][char[]]$XMLData
#Write-Host $XMLData

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
return $id
}

function create-printer {
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [int] $NK,#число
      [string] $Name,
      [string] $State,#В работе,Настройка/Модернизация,Планирование,Ремонт,Склад,Списан,Тестирование
      [string] $Incident,
      [string] $Description,
      [string] $Model,
      [string] $IPAddress,
      [string] $MACAddress
   )
   $UserLogin ="srv_otrs"
   $Password = "P@ssw0rd"

   if ($PSBoundParameters.Count -lt 6)
   {
      Write-Error -Message "Error. Check count Arguments!!! Need State Incident Description Model IPAddress MACAddress" -Category InvalidArgument
      Exit
   }

   $Description = $Description.Replace('<',' ').Replace('>','')
   $Model = $Model.Replace('<',' ').Replace('>','')   

   Write-Host "functions.ci create-printer $Name $State $Incident $Description $Model $IPAddress $MACAddress"
   #string strNumber = @"< Number > " + strName + @" </ Number >"
   #$strNK = "1137"
   
   $url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
     <soapenv:Body>
         <tic:Operation_CI_Create>
            <UserLogin>$UserLogin</UserLogin>
            <Password>$Password</Password>
            <ConfigItem>
                <Class>Printer</Class>
                <Name>$Name</Name>
                <DeplState>$State</DeplState>
                <InciState>$Incident</InciState>
                <CIXMLData><NK>$NK</NK><Description>$Description</Description><Model>$Model</Model><IPAddress>$IPAddress</IPAddress><MACAddress>$MACAddress</MACAddress></CIXMLData>
            </ConfigItem>
         </tic:Operation_CI_Create>
      </soapenv:Body>
</soapenv:Envelope>
"@


$enc_utf = [System.Text.Encoding]::UTF8
$Body = $enc_utf.GetBytes($XMLData)
#$Body = [byte[]][char[]]$XMLData
#Write-Host $XMLData

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
return $id
}


function search-id_forNK {
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )][string] $Class,
		[Parameter( Mandatory = $true )] [int] $NK#число
   )


   #string strNumber = @"< Number > " + strName + @" </ Number >"
   #$strNK = "1137"
   Write-Host "functions.ci search-id NK="$NK

   if ($Class -eq 'Computer'){ $pref = 'ARM' }
   elseif ($Class -eq 'Hardware') { $pref = 'HRDW' }
   elseif ($Class -eq 'Printer') { $pref = 'PRN' }
   switch ([string]$NK.Length) {
      1 { $strName = $pref + "-000" + $NK }
      2 { $strName = $pref +"-00" + $NK }
      3 { $strName = $pref +"-0" + $NK }
      Default {$strName = $pref + "-" + $NK}
   }
   $url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
     <soapenv:Body>
         <tic:Operation_CI_Search>
            <UserLogin>srv_otrs</UserLogin>
            <Password>P@ssw0rd</Password>
            <ConfigItem>
                <Class>$Class</Class>
                <CIXMLData><NK>$NK</NK></CIXMLData>
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
#Write-Host response $response
$requestStream = $response.GetResponseStream()
$readStream = New-Object System.IO.StreamReader $requestStream
$data = $readStream.ReadToEnd()
#Write-Host data $data
$id = ([xml]$data).Envelope.Body.Operation_CI_SearchResponse.ConfigItemIDs
if ($id -eq ""){$id = $null}
return $id
}

function update-computer {
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [string] $ConfigItemID,
      [Parameter( Mandatory = $true )] [int] $NK,
      [string] $Owner,
      [string] $State,#В работе,Настройка/Модернизация,Планирование,Ремонт,Склад,Списан,Тестирование
      [string] $Incident,
      [string] $Network,#Internet,Local,Other,КСПД,Секрет
      [string] $Type,#Десктоп,Другое,Ноубук,Планшет,Сервер,Телефон
      [string] $Description,
      [string] $Model,
      [string] $Secure
   )


   #string strNumber = @"< Number > " + strName + @" </ Number >"
   #$strNK = "1137"
   switch (([string]$NK).Length) {
      1 { $Name = "ARM-000" + $NK }
      2 { $Name = "ARM-00" + $NK }
      3 { $Name = "ARM-0" + $NK }
      Default {$Name = "ARM-" + $NK}
   }
   $url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
     <soapenv:Body>
         <tic:Operation_CI_Update>
            <UserLogin>srv_otrs</UserLogin>
            <Password>P@ssw0rd</Password>
            <ConfigItemID>$ConfigItemID</ConfigItemID>
            <ConfigItem>
                <Class>Computer</Class>
                <Name>$Name</Name>
                <DeplState>$State</DeplState>
                <InciState>$Incident</InciState>
                <CIXMLData><Owner>$Owner</Owner><Network>$Network</Network><Description>$Description</Description><Model>$Model</Model><Secure>$Secure</Secure></CIXMLData>
            </ConfigItem>
         </tic:Operation_CI_Update>
      </soapenv:Body>
</soapenv:Envelope>
"@


$enc_utf = [System.Text.Encoding]::UTF8
$Body = $enc_utf.GetBytes($XMLData)
#$Body = [byte[]][char[]]$XMLData
#Write-Host $Body

$Request = [System.Net.HttpWebRequest]::Create($url)
$Request.Headers.Add("SOAPAction", "http://www.otrs.org/Connector/Operation_CI_Update")
$Request.Method="POST"
$Request.Accept="text/xml"
$Request.ContentType="application/xml"
$Request.KeepAlive = $false
$Stream = $Request.GetRequestStream()
$Stream.Write($Body,0,$Body.Length)
$response = $Request.GetResponse()
#Write-Host response $response
$requestStream = $response.GetResponseStream()
$readStream = New-Object System.IO.StreamReader $requestStream
$data = $readStream.ReadToEnd()
#Write-Host data $data
$id = ([xml]$data).Envelope.Body.Operation_CI_UpdateResponse.ConfigItemID
return $id
}

function create-hardware {
   [CmdletBinding()]
	param (
		[Parameter( Mandatory = $true )] [int] $NK,#число
      [string] $Owner,
      [string] $State,#В работе,Настройка/Модернизация,Планирование,Ремонт,Склад,Списан,Тестирование
      [string] $Incident,
      [string] $Network,#Internet,Local,Other,КСПД,Секрет
      [string] $Type,#СХД,Сканер,Монитор,Модем,Камера
      [string] $Description,
      [string] $Model,
      [string] $Secure
   )


   #string strNumber = @"< Number > " + strName + @" </ Number >"
   #$strNK = "1137"
   switch (([string]$NK).Length) {
      1 { $strName = "HRDW-000" + $NK }
      2 { $strName = "HRDW-00" + $NK }
      3 { $strName = "HRDW-0" + $NK }
      Default {$strName = "HRDW-" + $NK}
   }
   $url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
     <soapenv:Body>
         <tic:Operation_CI_Create>
            <UserLogin>srv_otrs</UserLogin>
            <Password>P@ssw0rd</Password>
            <ConfigItem>
                <Class>Hardware</Class>
                <Name>$strName</Name>
                <DeplState>$State</DeplState>
                <InciState>$Incident</InciState>
                <CIXMLData><NK>$NK</NK><Owner>$Owner</Owner><Network>$Network</Network><Type>$Type</Type><Description>$Description</Description><Model>$Model</Model></CIXMLData>
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
#Write-Host response $response
$requestStream = $response.GetResponseStream()
$readStream = New-Object System.IO.StreamReader $requestStream
$data = $readStream.ReadToEnd()
#Write-Host data $data
$id = ([xml]$data).Envelope.Body.Operation_CI_CreateResponse.ConfigItemID
return $id
}

function update-hardware {
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [string] $ConfigItemID,#число
      [Parameter( Mandatory = $true )] [int] $NK,
      [string] $Owner,
      [string] $State,#В работе,Настройка/Модернизация,Планирование,Ремонт,Склад,Списан,Тестирование
      [string] $Incident,
      [string] $Network,#Internet,Local,Other,КСПД,Секрет
      [string] $Description,
      [string] $Model,
      [string] $Secure
   )
#NK не может измениться
switch (([string]$NK).Length) {
   1 { $Name = "HRDW-000" + $NK }
   2 { $Name = "HRDW-00" + $NK }
   3 { $Name = "HRDW-0" + $NK }
   Default {$Name = "HRDW-" + $NK}
}

   $url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
     <soapenv:Body>
         <tic:Operation_CI_Update>
            <UserLogin>srv_otrs</UserLogin>
            <Password>P@ssw0rd</Password>
            <ConfigItemID>$ConfigItemID</ConfigItemID>
            <ConfigItem>
                <Class>Hardware</Class>
                <Name>$Name</Name>
                <DeplState>$State</DeplState>
                <InciState>$Incident</InciState>
                <CIXMLData><Owner>$Owner</Owner><Network>$Network</Network><Description>$Description</Description><Model>$Model</Model></CIXMLData>
            </ConfigItem>
         </tic:Operation_CI_Update>
      </soapenv:Body>
</soapenv:Envelope>
"@


$enc_utf = [System.Text.Encoding]::UTF8
$Body = $enc_utf.GetBytes($XMLData)
#$Body = [byte[]][char[]]$XMLData
#Write-Host $Body

$Request = [System.Net.HttpWebRequest]::Create($url)
$Request.Headers.Add("SOAPAction", "http://www.otrs.org/Connector/Operation_CI_Update")
$Request.Method="POST"
$Request.Accept="text/xml"
$Request.ContentType="application/xml"
$Request.KeepAlive = $false
$Stream = $Request.GetRequestStream()
$Stream.Write($Body,0,$Body.Length)
$response = $Request.GetResponse()
#Write-Host response $response
$requestStream = $response.GetResponseStream()
$readStream = New-Object System.IO.StreamReader $requestStream
$data = $readStream.ReadToEnd()
#Write-Host data $data
$id = ([xml]$data).Envelope.Body.Operation_CI_UpdateResponse.ConfigItemID
return $id
}


#create-computer 3547 DanilovEB 'В работе' 'Исправен' 'Local' 'Десктоп' 'описание' 'модель' ''
#update-computer 4689 3 DanilovEB 'В работе' 'Исправен' 'Local' 'Десктоп' 'описание2' 'модель' 'No'
#create-hardware 2337 DanilovEB 'В работе' 'Исправен' 'Local' 'СХД' 'описание' 'модель' 'No'
#update-hardware 4688 2337 DanilovEB 'Склад' 'Исправен' 'Local' 'описание2' 'модель' 'No'
#create-location Корпус98 Daniloveb
#search-id Hardware 2338
#create-computer 3003 MarkovPI 'В работе' 'Исправен' 'Local' 'Десктоп' 'описание' 'модель' ''
#create-printer 3547 'PRN 1142_HP_LJ1120' 'В работе' 'Исправен' '' 'HP_LJ1120' '192.168.21.142' '00-00-00-00-00-00'
