function article-create {
   [CmdletBinding()]
	param (
	[Parameter( Mandatory = $true )] [string] $UserLogin,
    [Parameter( Mandatory = $true )] [string] $Password,
    [Parameter( Mandatory = $true )] [int] $TicketID,
    [Parameter( Mandatory = $true )] [string] $SenderType,
    [Parameter( Mandatory = $true )] [int] $IsVisibleForCustomer,
    [Parameter( Mandatory = $true )] [int] $UserID,
    [Parameter( Mandatory = $true )] [string] $MessageText,
    [Parameter( Mandatory = $true )] [int] $ChatterID
   )
   
$CreateTime = Get-Date -Format u
#Write-Host $CreateTime

   $url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_Ticket"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
   <soapenv:Body>
         <tic:Operation_ArticleCreate>
            <UserLogin>$UserLogin</UserLogin>
            <Password>$Password</Password>
            <ArticleBackendObject>ArticleCreate</ArticleBackendObject>
            <TicketID>$TicketID</TicketID>
            <SenderType>$SenderType</SenderType>
            <IsVisibleForCustomer>$IsVisibleForCustomer</IsVisibleForCustomer>
            <UserID>$UserID</UserID>
            <ChatterID>$ChatterID</ChatterID>
            <MessageText>$MessageText</MessageText>
            <CreateTime>$CreateTime</CreateTime>
         </tic:Operation_ArticleCreate>
      </soapenv:Body>
</soapenv:Envelope>
"@


#Write-Host $XMLData

   $enc_utf = [System.Text.Encoding]::UTF8
   $Body = $enc_utf.GetBytes($XMLData)
   #Body = [byte[]][char[]]$XMLData
   #Write-Host $Body

   $Request = [System.Net.HttpWebRequest]::Create($url)
   $Request.Headers.Add("SOAPAction", "http://www.otrs.org/Connector/Operation_ArticleCreate")
   $Request.Method="POST"
   $Request.Accept="text/xml"
   $Request.ContentType="application/xml"
   $Request.KeepAlive = $false
   $Stream = $Request.GetRequestStream()
   $Stream.Write($Body,0,$Body.Length)
   $Request.GetResponse()
}




#link-create srv_otrs P@ssw0rd ITSMConfigItem 3153 Ticket 1345 
article-create srv_otrs P@ssw0rd 1403 agent 1 2 MyMessage 1