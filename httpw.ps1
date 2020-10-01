#string strNumber = @"< Number > " + strName + @" </ Number >"
$strNK = "1140"
$strName = "arm-1140"
$strFIO = "Daniloveb@novator.ru"
$url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData3 = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
   <soapenv:Body>
      <tic:Operation_CI_Create>
         <UserLogin>srv_otrs</UserLogin>
         <Password>P@ssw0rd</Password>
      <ConfigItem>
                <Class>Computer</Class>
                <Name>$strName</Name>
                <DeplState>Production</DeplState>
                <InciState>Operational</InciState>
                <CIXMLData><CINumber>$strNK</CINumber><Owner>$strFIO</Owner></CIXMLData>
         </ConfigItem>
      </tic:Operation_CI_Create>
   </soapenv:Body>
</soapenv:Envelope>
"@



$Body = [byte[]][char[]]$XMLData3
#Write-Host $Body

$Request = [System.Net.HttpWebRequest]::Create($url)
$Request.Headers.Add("SOAPAction", "http://www.otrs.org/Connector/Operation_CI_Create")
$Request.Method="POST"
$Request.Accept="text/xml"
$Request.ContentType="application/xml"
$Request.KeepAlive = $false
$Stream = $Request.GetRequestStream()
$Stream.Write($Body,0,$Body.Length)
$Request.GetResponse()















#$response = $request.GetResponse()
#$requestStream = $response.GetResponseStream()
#$readStream = New-Object System.IO.StreamReader $requestStream
#$data=$readStream.ReadToEnd()
#if($response.ContentType -match "application/xml") {
#    $results = [xml]$data
#} elseif($response.ContentType -match "application/json") {
#    $results = $data | ConvertFrom-Json
#} else {
#    try {
#        $results = [xml]$data
#    } catch {
#        $results = $data | ConvertFrom-Json
#    }
#}
#$results 






$XMLData = "<?xml version='1.0' encoding='UTF-8'?>`
<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:tic=""http://www.otrs.org/TicketConnector/"">`
   <soapenv:Body>`
      <tic:Operation_CI_Create>`
         <UserLogin>daniloveb</UserLogin>`
         <Password>Hjkijhnnh6</Password>`
      <ConfigItem>`
                <Class>Kit</Class>`
                <Number>" + $strNK + "</Number>`
                <Name>" + $strName + "</Name>`
                <DeplState>Production</DeplState>`
                <InciState>Operational</InciState>`
                <CIXMLData><NK>" + $strNK + "</NK><FIO>" + $strFIO + "</FIO></CIXMLData>`
         </ConfigItem>`
      </tic:Operation_CI_Create>`
   </soapenv:Body>`
</soapenv:Envelope>"