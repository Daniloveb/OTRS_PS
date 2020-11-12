$ClassName = "Hardware"
function new-hardware {
   <#
   .SYNOPSIS
   OTRS SOAP Action for create Configuration Item: Hardware
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
   and copy backend perl module + import conf file for class Computer.
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER ConfigItemID
   CI id - function search-id
   .PARAMETER NK
   Number of ConfigItem
   .PARAMETER State 
   ITSM::ConfigItem::DeploymentState
   .PARAMETER Incident
   ITSM::Core::IncidentStatу
   .PARAMETER OWNER 
   Customer User owner CI. for LDAP user - SAMAccountName
   .PARAMETER Type
   ITSM::ConfigItem::Hardware::Type
   .PARAMETER Description
   string field
   .PARAMETER Model
   string field
   .PARAMETER SerialNumber
   string field
   .PARAMETER Network
   ITSM::ConfigItem::Network::Type
   .EXAMPLE
   new-hardware  7777 'В работе' 'Исправен' DanilovEB 'СХД' 'описание' 'модель' 'No' 'Local'
   #>
    [CmdletBinding()]
     param (
       [Parameter( Mandatory = $true )][int] $NK,#число
       [Parameter( Mandatory = $true )][string] $State,#В работе,Настройка/Модернизация,Планирование,Ремонт,Склад,Списан,Тестирование
       [Parameter( Mandatory = $true )][string] $Incident,
       [string] $Owner,
       [string] $Type,#СХД,Сканер,Монитор,Модем,Камера
       [string] $Description,
       [string] $Model,
       [string] $SerialNumber,
       [string] $Network #Internet,Local,Other,КСПД,Секрет
    )
    . "$PSScriptRoot\functions.SOAP.ps1"
    . "$PSScriptRoot\Set-GlobalVars.ps1"
   
    $Description = $Description.Replace('<',' ').Replace('>','')
    $Model = $Model.Replace('<',' ').Replace('>','')

    Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
    $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

    switch (([string]$NK).Length) {
       1 { $strName = "HRDW-000" + $NK }
       2 { $strName = "HRDW-00" + $NK }
       3 { $strName = "HRDW-0" + $NK }
       Default {$strName = "HRDW-" + $NK}
    }
    
    $WebServiceName = "WS_CI"
    $OperationName = "Operation_CI_Create"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
      <soapenv:Body>
          <tic:$OperationName>
             <UserLogin>srv_otrs</UserLogin>
             <Password>P@ssw0rd</Password>
             <ConfigItem>
                 <Class>$ClassName</Class>
                 <Name>$strName</Name>
                 <DeplState>$State</DeplState>
                 <InciState>$Incident</InciState>
                 <CIXMLData><NK>$NK</NK><Owner>$Owner</Owner><Type>$Type</Type><Description>$Description</Description><Model>$Model</Model><SerialNumber>$SerialNumber</SerialNumber><Network>$Network</Network></CIXMLData>
             </ConfigItem>
          </tic:$OperationName>
       </soapenv:Body>
</soapenv:Envelope>
"@
 
$data = request-SOAP $WebServiceName $OperationName $XMLData

$id = ([xml]$data).Envelope.Body.Operation_CI_CreateResponse.ConfigItemID
return $id
}

 function update-hardware {
     <#
  .SYNOPSIS
  OTRS SOAP Action for update Configuration Item: Hardware
  .DESCRIPTION
  For use this functions you have to create SOAP Webservice with named operation
  and copy backend perl module + import conf file for class Hardware.
  All parameters will update: not set value = null value in OTRS.
  Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
  .PARAMETER NK
  Number of ConfigItem
  .PARAMETER State 
  ITSM::ConfigItem::DeploymentState
  .PARAMETER Incident
  ITSM::Core::IncidentStatу
  .PARAMETER OWNER 
  Customer User owner CI. for LDAP user - SAMAccountName
  .PARAMETER Type
   ITSM::ConfigItem::Hardware::Type
   .PARAMETER Description
   string field
   .PARAMETER Model
   string field
   .PARAMETER SerialNumber
   string field
   .PARAMETER Network
   ITSM::ConfigItem::Network::Type
  #>
    [CmdletBinding()]
     param (
       [Parameter( Mandatory = $true )] [int] $ConfigItemID,
       [Parameter( Mandatory = $true )][int] $NK,#число
       [Parameter( Mandatory = $true )][string] $State,#В работе,Настройка/Модернизация,Планирование,Ремонт,Склад,Списан,Тестирование
       [Parameter( Mandatory = $true )][string] $Incident,
       [string] $Owner,
       [string] $Type,#СХД,Сканер,Монитор,Модем,Камера
       [string] $Description,
       [string] $Model,
       [string] $SerialNumber,
       [string] $Network #Internet,Local,Other,КСПД,Секрет
    )
 
    . "$PSScriptRoot\functions.SOAP.ps1"
    . "$PSScriptRoot\Set-GlobalVars.ps1"
 
    $Description = $Description.Replace('<',' ').Replace('>','')
    $Model = $Model.Replace('<',' ').Replace('>','')
 
    Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
    $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

   switch (([string]$NK).Length) {
     1 { $Name = "HRDW-000" + $NK }
     2 { $Name = "HRDW-00" + $NK }
     3 { $Name = "HRDW-0" + $NK }
     Default {$Name = "HRDW-" + $NK}
   }
 
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
                 <CIXMLData><NK>$NK</NK><Owner>$Owner</Owner><Type>$Type</Type><Description>$Description</Description><Model>$Model</Model><SerialNumber>$SerialNumber</SerialNumber><Network>$Network</Network></CIXMLData>
             </ConfigItem>
          </tic:$OperationName>
       </soapenv:Body>
</soapenv:Envelope>
"@
 
$data = request-SOAP $WebServiceName $OperationName $XMLData
 
$id = ([xml]$data).Envelope.Body.Operation_CI_UpdateResponse.ConfigItemID
return $id
}
