function get-ConfigItemId {
    <#
    .SYNOPSIS
    OTRS SOAP Action for search id ConfigItem from otrs db
    .DESCRIPTION
    You have to set Name OR NK property(if you have this)
    NK must be INTEGER!!! 
    For use this functions you have to create SOAP Webservice with named operation.
    Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
    .PARAMETER Class
    ITSM::ConfigItem::Class. Example Computer, Hardware...
    .PARAMETER NK
    ConfigItem Name or CI Number field
    .EXAMPLE
   get-ConfigItemId Computer 3456 or get-ConfigItemId Computer arm-3456
   get-ConfigItemId Printer 1227
   .LINK
   https://github/daniloveb/otrs_ps
    #>
    [CmdletBinding()]
     param (
       [Parameter( Mandatory = $true )] [string] $Class,
       $NK
    )

    . "$PSScriptRoot\functions.SOAP.ps1"
    . "$PSScriptRoot\Set-GlobalVars.ps1"

    Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
    #$Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")
    $WebServiceName = "WS_CI"
    $OperationName = "Operation_CI_Search" 

   #check parameter type 
if ($NK -is [int]){ 
    #search on NK field
$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
      <soapenv:Body>
          <tic:$OperationName>
             <UserLogin>$UserLogin</UserLogin>
             <Password>$Password</Password>
             <ConfigItem>
                 <Class>$Class</Class>
                 <CIXMLData><NK>$NK</NK></CIXMLData>
             </ConfigItem>
          </tic:$OperationName>
       </soapenv:Body>
</soapenv:Envelope>
"@
}
else   { 
$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
         <soapenv:Body>
                <tic:$OperationName>
                   <UserLogin>$UserLogin</UserLogin>
                   <Password>$Password</Password>
                   <ConfigItem>
                       <Class>$Class</Class>
                       <Name>$NK</Name>
                   </ConfigItem>
                </tic:$OperationName>
         </soapenv:Body>
</soapenv:Envelope>
"@
}

$data = request-SOAP $WebServiceName $OperationName $XMLData
 
$id = ([xml]$data).Envelope.Body.Operation_CI_SearchResponse.ConfigItemIDs
if ($id -eq ""){
      $id = $null
   }
return $id
}

function get-ConfigItem {
   <#
   .SYNOPSIS
   OTRS SOAP Action for get ConfigItem object from otrs db
   .DESCRIPTION
   Return hash table properties
   "Class"
   "CurDeplState"
   "CurDeplStateType"
   "CurInciState"
   "CurInciStateType"
   "Name"
   "VersionID"
   For use this functions you have to create SOAP Webservice with named operation.
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER ConfigItemID
   ITSM::ConfigItem::Id
   .EXAMPLE
   get-ConfigItem 4839
   $Name=(get-ConfigItem 4839)['Name']
   $Class=(get-ConfigItem 4839)['Class']
  .LINK
  https://github/daniloveb/otrs_ps
   #>
   [CmdletBinding()]
    param (
      [Parameter( Mandatory = $true, ValueFromPipeline = $true )] [string] $ConfigItemID
   )

   . "$PSScriptRoot\functions.SOAP.ps1"
   . "$PSScriptRoot\Set-GlobalVars.ps1"

   Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
   #$Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

   $WebServiceName = "WS_CI"
   $OperationName = "Operation_CI_Get"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
     <soapenv:Body>
         <tic:$OperationName>
            <UserLogin>$UserLogin</UserLogin>
            <Password>$Password</Password>
            <ConfigItemID>$ConfigItemID</ConfigItemID>
         </tic:$OperationName>
      </soapenv:Body>
</soapenv:Envelope>
"@

$data = request-SOAP $WebServiceName $OperationName $XMLData
$result = @{}
$result.add("Class",([xml]$data).Envelope.Body.Operation_CI_GetResponse.ConfigItem.Class)
$result.add("CurDeplState",([xml]$data).Envelope.Body.Operation_CI_GetResponse.ConfigItem.CurDeplState)
$result.add("CurDeplStateType",([xml]$data).Envelope.Body.Operation_CI_GetResponse.ConfigItem.CurDeplStateType)
$result.add("CurInciState",([xml]$data).Envelope.Body.Operation_CI_GetResponse.ConfigItem.CurInciState)
$result.add("CurInciStateType", ([xml]$data).Envelope.Body.Operation_CI_GetResponse.ConfigItem.CurInciStateType)
$result.add("Name",([xml]$data).Envelope.Body.Operation_CI_GetResponse.ConfigItem.Name)
$result.add("VersionID",([xml]$data).Envelope.Body.Operation_CI_GetResponse.ConfigItem.VersionID)

return $result
}

#$id = get-configitemid Computer 4438
#Write-Host $id