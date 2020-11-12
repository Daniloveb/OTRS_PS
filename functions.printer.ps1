$ClassName = "Printer"
function new-printer {
    <#
   .SYNOPSIS
   OTRS SOAP Action for create Configuration Item: Printer
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
   and copy backend perl module + import conf file for class Computer.
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER NK
   Number of ConfigItem
   .PARAMETER NAME
   Printer name
   .PARAMETER OWNER 
   Customer User owner CI. for LDAP user - SAMAccountName
   .PARAMETER State 
   ITSM::ConfigItem::DeploymentState
   .PARAMETER Incident
   ITSM::Core::IncidentStatу
   .PARAMETER Description
   string field
   .PARAMETER Model
   string field
   .PARAMETER Secure
   string field
   .PARAMETER IPAddress
   string field
   .PARAMETER MACAddress
   string field
   .EXAMPLE
   new-printer 5555 'PRN 5555_HP_LJ1120' 'В работе' 'Исправен' ' ' 'HP_LJ1120' '192.168.21.142' '00-00-00-00-00-00'
   .LINK
   https://github/daniloveb/otrs_ps
   #>
    [CmdletBinding()]
     param (
       [Parameter( Mandatory = $true )] [int] $NK,#число
       [Parameter( Mandatory = $true )] [string] $Name,
       [Parameter( Mandatory = $true )] [string] $State,#В работе,Настройка/Модернизация,Планирование,Ремонт,Склад,Списан,Тестирование
       [Parameter( Mandatory = $true )] [string] $Incident,
       [Parameter( Mandatory = $true )] [string] $Description,
       [Parameter( Mandatory = $true )] [string] $Model,
       [Parameter( Mandatory = $true )] [string] $IPAddress,
       [Parameter( Mandatory = $true )] [string] $MACAddress
    )
    . "$PSScriptRoot\functions.SOAP.ps1"
    . "$PSScriptRoot\Set-GlobalVars.ps1"
 
    $Description = $Description.Replace('<',' ').Replace('>','')
    $Model = $Model.Replace('<',' ').Replace('>','')
    if ($Description -eq ''){$Description = ' '}

    #Logging
    Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
    $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")
 
    $WebServiceName = "WS_CI"
    $OperationName = "Operation_CI_Create"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
      <soapenv:Body>
          <tic:$OperationName>
             <UserLogin>$UserLogin</UserLogin>
             <Password>$Password</Password>
             <ConfigItem>
                 <Class>$ClassName</Class>
                 <Name>$Name</Name>
                 <DeplState>$State</DeplState>
                 <InciState>$Incident</InciState>
                 <CIXMLData><NK>$NK</NK><Description>$Description</Description><Model>$Model</Model><IPAddress>$IPAddress</IPAddress><MACAddress>$MACAddress</MACAddress></CIXMLData>
             </ConfigItem>
          </tic:$OperationName>
       </soapenv:Body>
</soapenv:Envelope>
"@
 
$data = request-SOAP $WebServiceName $OperationName $XMLData
 
$id = ([xml]$data).Envelope.Body.Operation_CI_CreateResponse.ConfigItemID
return $id
}
 

function update-printer {
   <#
  .SYNOPSIS
  OTRS SOAP Action for update Configuration Item: Printer
  .DESCRIPTION
  For use this functions you have to create SOAP Webservice with named operation
  and copy backend perl module + import conf file for class Printer.
  All parameters will update: not set value = null value in OTRS.
  Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
  .PARAMETER ConfigItemID
  ConfigItem id
  .PARAMETER NK
  Number of ConfigItem
  .PARAMETER NAME
  Printer name
  .PARAMETER OWNER 
  Customer User owner CI. for LDAP user - SAMAccountName
  .PARAMETER State 
  ITSM::ConfigItem::DeploymentState
  .PARAMETER Incident
  ITSM::Core::IncidentStatу
  .PARAMETER Description
  string field
  .PARAMETER Model
  string field
  .PARAMETER Secure
  string field
  .PARAMETER IPAddress
  string field
  .PARAMETER MACAddress
  string field
   .EXAMPLE
   update-printer 11163 5555 'PRN 5555_HP_LJ1120' 'В работе' 'Исправен' 'new descr ' 'HP_LJ1120' '192.168.21.142' '00-00-00-00-00-00'
   .LINK
   https://github/daniloveb/otrs_ps
  #>
   [CmdletBinding()]
    param (
      [Parameter( Mandatory = $true )] [int] $ConfigItemID,
      [Parameter( Mandatory = $true )] [int] $NK,#число
      [Parameter( Mandatory = $true )] [string] $Name,
      [Parameter( Mandatory = $true )] [string] $State,#В работе,Настройка/Модернизация,Планирование,Ремонт,Склад,Списан,Тестирование
      [Parameter( Mandatory = $true )] [string] $Incident,
      [Parameter( Mandatory = $true )] [string] $Description,
      [Parameter( Mandatory = $true )] [string] $Model,
      [Parameter( Mandatory = $true )] [string] $IPAddress,
      [Parameter( Mandatory = $true )] [string] $MACAddress
   )
   . "$PSScriptRoot\functions.SOAP.ps1"
   . "$PSScriptRoot\Set-GlobalVars.ps1"

   $Description = $Description.Replace('<',' ').Replace('>','')
   $Model = $Model.Replace('<',' ').Replace('>','')

   if ($Description -eq ''){$Description = ' '}

   #Logging
   Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
   $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

   $WebServiceName = "WS_CI"
   $OperationName = "Operation_CI_Update"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
     <soapenv:Body>
         <tic:$OperationName>
            <UserLogin>$UserLogin</UserLogin>
            <Password>$Password</Password>
            <ConfigItemID>$ConfigItemID</ConfigItemID>
            <ConfigItem>
                <Class>$ClassName</Class>
                <Name>$Name</Name>
                <DeplState>$State</DeplState>
                <InciState>$Incident</InciState>
                <CIXMLData><NK>$NK</NK><Description>$Description</Description><Model>$Model</Model><IPAddress>$IPAddress</IPAddress><MACAddress>$MACAddress</MACAddress></CIXMLData>
            </ConfigItem>
         </tic:$OperationName>
      </soapenv:Body>
</soapenv:Envelope>
"@

$data = request-SOAP $WebServiceName $OperationName $XMLData

$id = ([xml]$data).Envelope.Body.Operation_CI_CreateResponse.ConfigItemID
return $id
}


