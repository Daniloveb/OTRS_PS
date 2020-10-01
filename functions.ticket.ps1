
function ticket-create {
   [CmdletBinding()]
	param (
		[Parameter( Mandatory = $true )] [string] $UserLogin, #srv_otrs
      [Parameter( Mandatory = $true )] [string] $Password, 
      [Parameter( Mandatory = $true )] [string] $Title,
      [Parameter( Mandatory = $true )] [string] $CustomerLogin,
      [Parameter( Mandatory = $true )] [string] $Owner,
      [Parameter( Mandatory = $true )] [int] $QueryID, # использовал 1
      [Parameter( Mandatory = $true )] [int] $TicketStateID, # 4-> open, 2 -> closed
      [string] $ArticleSubject,
      [string] $ArticleBody
   )
   

#$strID = "5544"
#$description = "test_Title"
#$strFIO = "Daniloveb"
#$strCustomerLogin = "PolyakovMV"
#$CustomerID = $CustomerLogin + "@novator.ru"

$url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_Ticket"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
   <soapenv:Body>
      <tic:Operation_TicketCreate>
         <UserLogin>srv_otrs</UserLogin>
         <Password>P@ssw0rd</Password>
      <Ticket>
                <Title>$Title</Title>
                <CustomerUser>$CustomerLogin</CustomerUser>
                <CustomerID>NOVATOR</CustomerID>
                <QueueID>$QueryID</QueueID>
                <StateID>$TicketStateID</StateID>
                <PriorityID>2</PriorityID>
                <TypeID>2</TypeID>
                <Owner>$Owner</Owner>
                <LockID>1</LockID>
         </Ticket>
         <Article>
             <Subject>$ArticleSubject</Subject>
             <Body>$ArticleBody</Body>
             <ContentType>text/plain; charset=utf8</ContentType>
         </Article>
      </tic:Operation_TicketCreate>
   </soapenv:Body>
</soapenv:Envelope>
"@

$Request = [System.Net.HttpWebRequest]::Create($url)
$Request.Headers.Add("SOAPAction", "http://www.otrs.org/Connector/Operation_TicketCreate")
$Request.Method="POST"
$Request.Accept="text/xml"
$Request.ContentType="application/xml"
#$Request.ContentType="text/xml;charset=`"utf-8`""
$Request.KeepAlive = $true
$Request.UseDefaultCredentials = $true

$Stream = $Request.GetRequestStream()

#$Body = [byte[]][char[]]$XMLData

$enc_utf = [System.Text.Encoding]::UTF8
$Body = $enc_utf.GetBytes($XMLData)
$Stream.Write($Body,0,$Body.Length)

$response = $Request.GetResponse()
$requestStream = $response.GetResponseStream()
$readStream = New-Object System.IO.StreamReader $requestStream
$data = $readStream.ReadToEnd()
Write-Host data $data
$d = ([xml]$data).Envelope.Body.Operation_TicketCreateResponse.ArticleID
Write-Host d $d
}


#ticket-create srv_otrs P@ssw0rd test PolyakovMV DanilovEB 1 4 test_article_Subject test_article_боди

