#sample
#create-link ITSMConfigItem 3758 ITSMConfigItem 3774 Includes
function create-link {
   [CmdletBinding()]
	param (
	   [Parameter( Mandatory = $true )] [string] $SourceObject,
      [Parameter( Mandatory = $true )] [int] $SourceKey,
      [Parameter( Mandatory = $true )] [string] $TargetObject,
      [Parameter( Mandatory = $true )] [int] $TargetKey,
      [Parameter( Mandatory = $true )] [string] $Type
   )
   $UserLogin ="srv_otrs"
   $Password = "P@ssw0rd"

   Write-Host "functions.link create-link $SourceObject $SourceKey $TargetObject $TargetKey $Type"
#  [Parameter( Mandatory = $true )] [string] $UserLogin,
#  [Parameter( Mandatory = $true )] [string] $Password,
   #Type используем RelevantTo
   #Types
   # Normal ParentChild AlternativeTo DependsOn RelevantTo ConnectedTo

   $url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
      <soapenv:Body>
         <tic:Operation_Link_Add>
            <UserLogin>$UserLogin</UserLogin>
            <Password>$Password</Password>
            <LinkObject>LinkAdd</LinkObject>
            <SourceObject>$SourceObject</SourceObject>
            <SourceKey>$SourceKey</SourceKey>
            <TargetObject>$TargetObject</TargetObject>
            <TargetKey>$TargetKey</TargetKey>
            <Type>$Type</Type>
            <State>Valid</State>
            <UserID>4</UserID>
         </tic:Operation_Link_Add>
      </soapenv:Body>
</soapenv:Envelope>
"@

#Write-host $XMLData

   $enc_utf = [System.Text.Encoding]::UTF8
   $Body = $enc_utf.GetBytes($XMLData)
   #Body = [byte[]][char[]]$XMLData
   #Write-Host $Body

   $Request = [System.Net.HttpWebRequest]::Create($url)
   $Request.Headers.Add("SOAPAction", "http://www.otrs.org/Connector/Operation_Link_Add")
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
   return
}

function delete-link {
   [CmdletBinding()]
	param (
		[Parameter( Mandatory = $true )] [string] $UserLogin,
      [Parameter( Mandatory = $true )] [string] $Password,
      [Parameter( Mandatory = $true )] [string] $Object1,
      [Parameter( Mandatory = $true )] [int] $Key1,
      [Parameter( Mandatory = $true )] [string] $Object2,
      [Parameter( Mandatory = $true )] [int] $Key2
   )
   
$url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
   <soapenv:Body>
      <tic:Operation_Link_Delete>
         <UserLogin>$UserLogin</UserLogin>
         <Password>$Password</Password>
         <LinkObject>LinkDelete</LinkObject>
            <Object1>$Object1</Object1>
            <Key1>$Key1</Key1>
            <Object2>$Object2</Object2>
            <Key2>$Key2</Key2>
            <Type>$Type</Type>
            <UserID>1</UserID>
      </tic:Operation_Link_Delete>
   </soapenv:Body>
</soapenv:Envelope>
"@

#$Body = [byte[]][char[]]$XMLData
$enc_utf = [System.Text.Encoding]::UTF8
$Body = $enc_utf.GetBytes($XMLData)

$Request = [System.Net.HttpWebRequest]::Create($url)
$Request.Headers.Add("SOAPAction", "http://www.otrs.org/Connector/Operation_Link_Delete")
$Request.Method="POST"
$Request.Accept="text/xml"
$Request.ContentType="application/xml"
$Request.KeepAlive = $false
$Stream = $Request.GetRequestStream()
$Stream.Write($Body,0,$Body.Length)
$Request.GetResponse()
return
}

function link-list {
   [CmdletBinding()]
	param (
	   [Parameter( Mandatory = $true )] [string] $Object,
      [Parameter( Mandatory = $true )] [int] $Key
   )
   $UserLogin ="srv_otrs"
   $Password = "P@ssw0rd"

   Write-Host "functions.link linklist $SourceObject "
#  [Parameter( Mandatory = $true )] [string] $UserLogin,
#  [Parameter( Mandatory = $true )] [string] $Password,
   #Type используем RelevantTo
   #Types
   # Normal ParentChild AlternativeTo DependsOn RelevantTo ConnectedTo

   $url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/WS_CI"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
      <soapenv:Body>
         <tic:Operation_Link_List>
            <UserLogin>$UserLogin</UserLogin>
            <Password>$Password</Password>
            <LinkObject>LinkList</LinkObject>
            <Object>$Object</Object>
            <Key>$Key</Key>
            <State>Valid</State>
            <UserID>1</UserID>
         </tic:Operation_Link_List>
      </soapenv:Body>
</soapenv:Envelope>
"@

#Write-host $XMLData

   $enc_utf = [System.Text.Encoding]::UTF8
   $Body = $enc_utf.GetBytes($XMLData)
   #Body = [byte[]][char[]]$XMLData
   #Write-Host $Body

   $Request = [System.Net.HttpWebRequest]::Create($url)
   $Request.Headers.Add("SOAPAction", "http://www.otrs.org/Connector/Operation_Link_List")
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
   Write-Host data $data
   return
}
#7700 arm-4983
#create-link ITSMConfigItem 7700 ITSMConfigItem 7701 Includes
#arm-4582 id 7301
link-list ITSMConfigItem 7301