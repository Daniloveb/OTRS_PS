function new-link {
    <#
   .SYNOPSIS
   OTRS SOAP Action for create link
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
   and copy backend perl module
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER SourceObject
   Object Type for Source object. Example = ITSMConfigItem
   .PARAMETER SourceKey 
   Id for Source Object
   .PARAMETER TargetObject
   Object Type for Target object. Example = ITSMConfigItem
   .PARAMETER TargetKey
   Id for Target Object
   .PARAMETER Type
   ITSM::ConfigItem::LinkObject::Type
   .PARAMETER State 
   public.link_state. Valid etc
   .PARAMETER UserId
   Id field from table public.users
   .EXAMPLE
   new-link ITSMConfigItem 7301 ITSMConfigItem 4840 ConnectedTo Valid 1
   .LINK
   https://github/daniloveb/otrs_ps
   #>
   [CmdletBinding()]
	param (
	   [Parameter( Mandatory = $true )] [string] $SourceObject,
      [Parameter( Mandatory = $true )] [int] $SourceKey,
      [Parameter( Mandatory = $true )] [string] $TargetObject,
      [Parameter( Mandatory = $true )] [int] $TargetKey,
      [Parameter( Mandatory = $true )] [string] $Type,
      [Parameter( Mandatory = $true )] [string] $State,
      [Parameter( Mandatory = $true )] [string] $UserId
   )
   . "$PSScriptRoot\functions.SOAP.ps1"
   . "$PSScriptRoot\Set-GlobalVars.ps1"

   Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
   $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")
   #Type используем RelevantTo
   #Types: Normal ParentChild AlternativeTo DependsOn RelevantTo ConnectedTo
   #Default link type to location - ConnectedTo

   $WebServiceName = "WS_CI"
   $OperationName = "Operation_Link_Add"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
      <soapenv:Body>
         <tic:$OperationName>
            <UserLogin>$UserLogin</UserLogin>
            <Password>$Password</Password>
            <LinkObject>LinkAdd</LinkObject>
            <SourceObject>$SourceObject</SourceObject>
            <SourceKey>$SourceKey</SourceKey>
            <TargetObject>$TargetObject</TargetObject>
            <TargetKey>$TargetKey</TargetKey>
            <Type>$Type</Type>
            <State>$State</State>
            <UserID>$UserId</UserID>
         </tic:$OperationName>
      </soapenv:Body>
</soapenv:Envelope>
"@

   $data = request-SOAP $WebServiceName $OperationName $XMLData
}

function remove-link {
   <#
   .SYNOPSIS
   OTRS SOAP Action for create link
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
   and copy backend perl module
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER Object1
   Object Type for Source object. Example = ITSMConfigItem
   .PARAMETER Key1 
   Id for Source Object
   .PARAMETER Object2
   Object Type for Target object. Example = ITSMConfigItem
   .PARAMETER Key2
   Id for Target Object
   .PARAMETER Type
   ITSM::ConfigItem::LinkObject::Type
   .PARAMETER UserId
   Id field from table public.users
   .EXAMPLE
   remove-link ITSMConfigItem 7301 ITSMConfigItem 4839 ConnectedTo 1
   .LINK
   https://github/daniloveb/otrs_ps
   #>
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [string] $Object1,
      [Parameter( Mandatory = $true )] [int] $Key1,
      [Parameter( Mandatory = $true )] [string] $Object2,
      [Parameter( Mandatory = $true )] [int] $Key2,
      [Parameter( Mandatory = $true )][string] $Type, 
      [Parameter( Mandatory = $true )][string] $UserId
   )
   
   . "$PSScriptRoot\functions.SOAP.ps1"
   . "$PSScriptRoot\Set-GlobalVars.ps1"
   Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
   $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

   $WebServiceName = "WS_CI"
   $OperationName = "Operation_Link_Delete"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
   <soapenv:Body>
      <tic:$OperationName>
         <UserLogin>$UserLogin</UserLogin>
         <Password>$Password</Password>
         <LinkObject>LinkDelete</LinkObject>
            <Object1>$Object1</Object1>
            <Key1>$Key1</Key1>
            <Object2>$Object2</Object2>
            <Key2>$Key2</Key2>
            <Type>$Type</Type>
            <UserID>$UserId</UserID>
      </tic:$OperationName>
   </soapenv:Body>
</soapenv:Envelope>
"@

$data = request-SOAP $WebServiceName $OperationName $XMLData
$result = ([xml]$data).Envelope.Body.Operation_Link_DeleteResponse.Result
return $result
}

function link-list {
   <#
   .SYNOPSIS
   OTRS SOAP Action for get linked object
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
   and copy backend perl module + import conf file for class Computer.
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER ObjectType
   Type main object:: ITSMCofigItem, Ticket or...
   .PARAMETER Key 
   Id item
   .PARAMETER Object2Type
   Type linked object :: ITSMCofigItem, Ticket or...
   .PARAMETER State 
   public.link_state. Valid etc
   .PARAMETER UserId
   Id field from table public.users
   .EXAMPLE
   link-list ITSMConfigItem 7301 ITSMConfigItem Valid 1
   .LINK
   https://github/daniloveb/otrs_ps
   #>
   [CmdletBinding()]
	param (
	   [Parameter( Mandatory = $true )] [string] $ObjectType,
      [Parameter( Mandatory = $true )] [int] $Key,
      [string] $Object2Type,
      [Parameter( Mandatory = $true )][string] $State, # Valid
      [Parameter( Mandatory = $true )][string] $UserId # 1
   )

   . "$PSScriptRoot\functions.SOAP.ps1"
   . "$PSScriptRoot\Set-GlobalVars.ps1"

   Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
   #$Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

   #Type используем RelevantTo
   #Types
   # Normal ParentChild AlternativeTo DependsOn RelevantTo ConnectedTo

   $WebServiceName = "WS_CI"
   $OperationName = "Operation_Link_List"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
      <soapenv:Body>
         <tic:$OperationName>
            <UserLogin>$UserLogin</UserLogin>
            <Password>$Password</Password>
            <Object>$ObjectType</Object>
            <Key>$Key</Key>
            <Object2>$Object2Type</Object2>
            <State>$State</State>
            <UserID>$UserId</UserID>
         </tic:$OperationName>
      </soapenv:Body>
</soapenv:Envelope>
"@
   
   $data = request-SOAP $WebServiceName $OperationName $XMLData
   $ids = ([xml]$data).Envelope.Body.Operation_Link_ListResponse.Result
   #delete first array item 
   $ids = $ids | Where-Object {$_ -ne 1 }
   return $ids
}



