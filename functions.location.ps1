function new-location {
   <#
   .SYNOPSIS
   OTRS SOAP Action for create Configuration Item: Location
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
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

