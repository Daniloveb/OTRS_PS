<#
    .SYNOPSIS
    OTRS SOAP HTTP POST request
    .DESCRIPTION
    For use this functions you have to create SOAP Webservice with named operation
    and copy backend perl module.
    Webservice import yaml file, modules and more detail: https://github/daniloveb/otrs_ps
    .PARAMETER Url
    Link to Webservice
    .PARAMETER SOAPNameSpace
    Namespace from configuration WebService
    .PARAMETER OperationName
    Name of action. Must be added in configuration WebService
    .PARAMETER XMLData
    Request Body 
    #>
#[CmdletBinding()]
#param(
       #[Parameter( Mandatory = $true )] [string] $OperationName,
       #[Parameter( Mandatory = $true )] [string] $XMLData
#       )
#. "$PSScriptRoot\functions.location.ps1"
#. "$PSScriptRoot\functions.ci.ps1"
#. "$PSScriptRoot\functions.link.ps1"
#. "$PSScriptRoot\Set-GlobalVars.ps1"
#Set-GlobalVars

#create-printer 5555 'PRN 5555_HP_LJ1120' 'В работе' 'Исправен' ' ' 'HP_LJ1120' '192.168.21.142' '00-00-00-00-00-00' -Debug

. "$PSScriptRoot\get-logger.ps1"
#$Logger = Get-Logger
#$Logger.AddErrorRecord("uyiuyi")

#. "$PSScriptRoot\functions.SOAP.ps1"
#. "$PSScriptRoot\Set-GlobalVars.ps1"
#$Logger.AddInfoRecord("$($MyInvocation.ScriptName) $($MyInvocation.MyCommand.Name) $NK $Name $State $Incident $Description $Model $IPAddress $MACAddress")

#Write-Debug "$($MyInvocation.ScriptName) $($MyInvocation.MyCommand.Name) $($args[0]) $($args[1]) $($args[2]) $($args[3])"
#$Logger.AddInfoRecord("$($MyInvocation.ScriptName) $($MyInvocation.MyCommand.Name) $($args[0]) $($args[1]) $($args[2]) $($args[3]")
#   $Logger.AddInfoRecord("$($MyInvocation.ScriptName) $($args[0])")
#   Write-Debug "$($MyInvocation.ScriptName) $($MyInvocation.MyCommand.Name) $($args[0])"
#   Write-Debug "$($MyInvocation.ScriptName) $($MyInvocation.MyCommand.Name) $($args[0]) $($args[1]) $($args[2]) $($args[3])"
#   $Logger.AddInfoRecord("$($MyInvocation.ScriptName) $($MyInvocation.MyCommand.Name) $($args[0]) $($args[1]) $($args[2]) $($args[3]")

function func{
    [CmdletBinding()]
    param(
        [string] $arg1,
        [string] $arg2,
        [string] $arg3
    )
    #$($MyInvocation.BoundParameters.Values[0])
    #Write-Debug "$($MyInvocation.ScriptName) $($MyInvocation.MyCommand.Name) $($args[0]) $($args[1]) $($args[2]) $($args[3])"
    Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
    $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")
}

#func txt1 txt2 -Debug

# список тестовых запусков
#create-printer 5555 'PRN 5555_HP_LJ1120' 'В работе' 'Исправен' ' ' 'HP_LJ1120' '192.168.21.142' '00-00-00-00-00-00'
#update-printer 11163 5555 'PRN 5555_HP_LJ1120' 'В работе' 'Исправен' 'new descr ' 'HP_LJ1120' '192.168.21.142' '00-00-00-00-00-00'
#get-id Hardware 7777
#get-id Hardware 7777
#link-create srv_otrs P@ssw0rd ITSMConfigItem 3153 Ticket 1345 
#article-create 89859 agent 1 2
#create-ticket test PolyakovMV DanilovEB 1 4 3 2 1 test_article_Subject test_article_боди

. "$PSScriptRoot\functions.location.ps1"
. "$PSScriptRoot\functions.computer.ps1"
. "$PSScriptRoot\functions.link.ps1"
. "$PSScriptRoot\functions.share.ps1"
. "$PSScriptRoot\functions.ticket.ps1"

#update.all.computers 50
#
#get-ConfigItemId Computer 3456

#synch-computers 35

#get-ConfigItemId "Computer" 711

#synch-links 2

#4839 | Get-ConfigItem | ForEach-Object {$Name = $_.Name}
#$Name

#7700 arm-4983
#create-link ITSMConfigItem 7700 ITSMConfigItem 7701 Includes
#arm-4582 id 7301
#link-listwithdata ITSMConfigItem 7301  #арм-4582 -> 5437
#link-list ITSMConfigItem 7301 ITSMConfigItem Valid 1 #арм-4582 -> 5437
#remove-link ITSMConfigItem 7301 ITSMConfigItem 4839 ConnectedTo 1
#create-link ITSMConfigItem 7301 ITSMConfigItem 5378 ConnectedTo Valid 1

#link-list ITSMConfigItem 10288 ITSMConfigItem Valid 1

#$Name=(get-ConfigItem 4839)['Name']
#get-ConfigItemId Printer 'PRN 1227_HP_M1212'
#PRN 1227_HP_M1212
#get-ConfigItemId Printer 2122
#get-ConfigItemId Computer 2601

#get-ConfigItemId Location '57.2-С8-2'
#get-ConfigItemId Location '98-102'

#remove-link ITSMConfigItem 10658 ITSMConfigItem 5378 ConnectedTo 1
#get-ticket 54654

$ID_Personel = '0CA4BF12-67F4-4058-B9DD-74BCD354D9FF'
$u = Get-ADUser -f{extensionAttribute7 -eq $ID_Personel}
write-host $u.SamAccountName