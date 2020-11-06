function create-computer {
   <#
   .SYNOPSIS
   OTRS SOAP Action for create Configuration Item: Computer
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
   and copy backend perl module + import conf file for class Computer.
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER NK
   Number of ConfigItem
   .PARAMETER OWNER 
   Customer User owner CI. for LDAP user - SAMAccountName
   .PARAMETER State 
   ITSM::ConfigItem::DeploymentState
   .PARAMETER Incident
   ITSM::Core::IncidentState
   .PARAMETER Network
   ITSM::ConfigItem::Network::Type
   .PARAMETER Type
   ITSM::ConfigItem::Computer::Type
   .PARAMETER Description
   string field
   .PARAMETER Model
   string field
   .PARAMETER Secure
   string field
   .EXAMPLE
   update-computer 10019 3350 IvanovAE 'Склад' 'Исправен' 'Local' 'Desktop' 'description' 'model' 'No'
   .LINK
   https://github/daniloveb/otrs_ps
   #>
   [CmdletBinding()]
   param(
      [Parameter( Mandatory = $true )] [int] $NK,#int
      [string] $Owner,
      [string] $State,#В работе,Настройка/Модернизация,Планирование,Ремонт,Склад,Списан,Тестирование
      [string] $Incident,
      [string] $Network,#Internet,Local,Other,КСПД,Секрет
      [string] $Type,#Десктоп,Другое,Ноубук,Планшет,Сервер,Телефон
      [string] $Description,
      [string] $Model,
      [string] $Secure
   )
   . "$PSScriptRoot\functions.SOAP.ps1"
   . "$PSScriptRoot\Set-GlobalVars.ps1"
  
   $Description = $Description.Replace('<',' ').Replace('>','')
   $Model = $Model.Replace('<',' ').Replace('>','')

   Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
   $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

   #Naming on base int NK
   switch (([string]$NK).Length) {
      1 { $Name = "ARM-000" + $NK }
      2 { $Name = "ARM-00" + $NK }
      3 { $Name = "ARM-0" + $NK }
      Default {$Name = "ARM-" + $NK}
   }
   
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
                <Class>Computer</Class>
                <Name>$Name</Name>
                <DeplState>$State</DeplState>
                <InciState>$Incident</InciState>
                <CIXMLData><NK>$NK</NK><Owner>$Owner</Owner><Network>$Network</Network><Type>$Type</Type><Description>$Description</Description><Model>$Model</Model><Secure>$Secure</Secure></CIXMLData>
            </ConfigItem>
         </tic:$OperationName>
      </soapenv:Body>
</soapenv:Envelope>
"@

$data = request-SOAP $WebServiceName $OperationName $XMLData
$id = ([xml]$data).Envelope.Body.Operation_CI_CreateResponse.ConfigItemID
return $id
}


function update-computer {
    <#
   .SYNOPSIS
   OTRS SOAP Action for update Configuration Item: Computer
   CI Id search in file function.share  :search-id
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
   and copy backend perl module + import conf file for class Computer.
   All parameters will update: not set value = null value in OTRS.
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER ConfigItemID
   CI id - function search-id
   .PARAMETER NK
   Number of ConfigItem
   .PARAMETER OWNER 
   Customer User owner CI. for LDAP user - SAMAccountName
   .PARAMETER State 
   ITSM::ConfigItem::DeploymentState
   .PARAMETER Incident
   ITSM::Core::IncidentStatу
   .PARAMETER Network
   ITSM::ConfigItem::Network::Type
   .PARAMETER Type
   ITSM::ConfigItem::Computer::Type
   .PARAMETER Description
   string field
   .PARAMETER Model
   string field
   .PARAMETER Secure
   string field
   .EXAMPLE
   update-computer 10019 3350 IvanovAE 'Склад' 'Исправен' 'Local' 'Desktop' 'description' 'model' 'No'
   .LINK
   https://github/daniloveb/otrs_ps
   #>
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [int] $ConfigItemID,
      [Parameter( Mandatory = $true )] [int] $NK,
      [Parameter( Mandatory = $true )][string] $Owner,
      [Parameter( Mandatory = $true )][string] $State,#В работе,Настройка/Модернизация,Планирование,Ремонт,Склад,Списан,Тестирование
      [Parameter( Mandatory = $true )][string] $Incident,
      [string] $Network,#Internet,Local,Other,КСПД,Секрет
      [string] $Type,#Десктоп,Другое,Ноубук,Планшет,Сервер,Телефон
      [string] $Description,
      [string] $Model,
      [string] $Secure
   )
   . "$PSScriptRoot\functions.SOAP.ps1"
   . "$PSScriptRoot\Set-GlobalVars.ps1"
  
   $Description = $Description.Replace('<',' ').Replace('>','')
   $Model = $Model.Replace('<',' ').Replace('>','')

   Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
   $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

   switch (([string]$NK).Length) {
      1 { $Name = "ARM-000" + $NK }
      2 { $Name = "ARM-00" + $NK }
      3 { $Name = "ARM-0" + $NK }
      Default {$Name = "ARM-" + $NK}
   }
   
   $WebServiceName = "WS_CI"
   $OperationName = "Operation_CI_Update"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://www.otrs.org/Connector/">
     <soapenv:Body>
         <tic:$OperationName>
            <UserLogin>$UserLogin</UserLogin>
            <Password>$Password</Password>
            <ConfigItemID>$ConfigItemID</ConfigItemID>
            <ConfigItem>
                <Class>Computer</Class>
                <Name>$Name</Name>
                <DeplState>$State</DeplState>
                <InciState>$Incident</InciState>
                <CIXMLData><Owner>$Owner</Owner><Network>$Network</Network><Description>$Description</Description><Model>$Model</Model><Secure>$Secure</Secure></CIXMLData>
            </ConfigItem>
         </tic:$OperationName>
      </soapenv:Body>
</soapenv:Envelope>
"@

$data = request-SOAP $WebServiceName $OperationName $XMLData
$id = ([xml]$data).Envelope.Body.Operation_CI_UpdateResponse.ConfigItemID
return $id
}



#create-computer 6666 DanilovEB 'В работе' 'Исправен' 'Local' 'Десктоп' 'описание' 'модель' ''
#id 10019 arm-3350
#update-computer 10019 3350 YurlovYUE 'Склад' 'Исправен' #'Local' 'Десктоп' 'описание2' 'модель' 'No'
#update-computer 6262 711 ' ' 'Склад' 'Исправен' #'Local' 'Десктоп' 'описание2' 'модель' 'No'
#create-hardware 2337 DanilovEB 'В работе' 'Исправен' 'Local' 'СХД' 'описание' 'модель' 'No'
#update-hardware 4688 2337 DanilovEB 'Склад' 'Исправен' 'Local' 'описание2' 'модель' 'No'
#create-location Корпус98 Daniloveb
#search-id Hardware 2338
#create-computer 3003 MarkovPI 'В работе' 'Исправен' 'Local' 'Десктоп' 'описание' 'модель' ''
#create-printer 5555 'PRN 5555_HP_LJ1120' 'В работе' 'Исправен' '' 'HP_LJ1120' '192.168.21.142' '00-00-00-00-00-00'
