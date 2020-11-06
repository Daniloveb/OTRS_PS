function request-SOAP {
    <#
    .SYNOPSIS
    OTRS SOAP HTTP POST request
    .DESCRIPTION
    For use this functions you have to create SOAP Webservice with named operation and backend perl module.
    Webservice import yaml file, modules and more detail on github
    .PARAMETER Url
    Link to Webservice
    .PARAMETER SOAPNameSpace
    Namespace from configuration WebService
    .PARAMETER OperationName
    Name of action. Must be added in configuration WebService
    .PARAMETER XMLData
    Request Body 
    .LINK 
    https://github/daniloveb/otrs_ps
    #>
[CmdletBinding()]
param(
       [Parameter( Mandatory = $true )] [string] $WEBServiceName,
       [Parameter( Mandatory = $true )] [string] $OperationName,
       [Parameter( Mandatory = $true )] [string] $XMLData
       )
       Set-StrictMode -Version Latest
       $ErrorActionPreference='Stop'
       . "$PSScriptRoot\Set-GlobalVars.ps1"
        #Set-GlobalVars

        Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
        #for debug
        #$Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

$enc_utf = [System.Text.Encoding]::UTF8
$Body = $enc_utf.GetBytes($XMLData)

$Request = [System.Net.HttpWebRequest]::Create("$Url$WEBServiceName")
#$Request.Headers.Add("SOAPAction", "http://www.otrs.org/Connector/Operation_CI_Create")

$Request.Headers.Add("SOAPAction", "$SOAPNameSpace$OperationName")
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
return $data
}


#SOAP.Request 1 2 3 4