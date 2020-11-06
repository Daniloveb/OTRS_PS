function create-location {
   <#
   .SYNOPSIS
   OTRS SOAP Action for create Configuration Item: Computer
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
   and copy backend perl module + import conf file for class Computer.
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER Name
   Location Name
   .PARAMETER State 
   ITSM::ConfigItem::DeploymentState
   .PARAMETER Incident
   ITSM::Core::IncidentState
   .PARAMETER Type
   ITSM::ConfigItem::Location::Type
   #>
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [string] $Name,
      [Parameter( Mandatory = $true )] [string] $State,
      [Parameter( Mandatory = $true )] [string] $Incident,
      [Parameter( Mandatory = $true )] [string] $Type 
   )
   . "$PSScriptRoot\functions.SOAP.ps1"
   . "$PSScriptRoot\Set-GlobalVars.ps1"

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
                <Class>Location</Class>
                <Name>$Name</Name>
                <DeplState>$State</DeplState>
                <InciState>$Incident</InciState>
                <CIXMLData><Type>$Type</Type></CIXMLData>
         </ConfigItem>
      </tic:$OperationName>
   </soapenv:Body>
</soapenv:Envelope>
"@

$data = request-SOAP $WebServiceName $OperationName $XMLData
$id = ([xml]$data).Envelope.Body.Operation_CI_CreateResponse.ConfigItemID
return $id
}



#работает только для комплектов
#для принтеров и UPS префиксы отличаются во view v_MACs_forLookup  




#PrinterName вида "PRN 2071_Ricoh_SP230"


#computer-Create -NK "1500" -Owner "Daniloveb"
#create-computer 1635 DanilovEB 'В работе' 'Исправен' 'Local' 'Десктоп'
#search-location Корпус98
#create-location 'Корпус 72' Здание
#search-location-forNK Computer 4104
#search-LocationName-forNK Computer 4104
#search-location_id-for_name 98-102
#search-location_name-for_PrinterName "PRN 2071_Ricoh_SP230"
#search-location_name-for_NK 4104

#search-locationid-for_loc_name Location -Name "98-111"
#search-locationid-for_loc_name Computer -NK "4500"