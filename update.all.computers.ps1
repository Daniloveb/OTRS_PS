﻿# v1 Создаем и обновляем компьютеры и привязываем к пользователям
# для записей из ParkPC измененных за последние $Days
param (
    [Parameter( Mandatory = $true )] [int] $Days) #число)
    
#=====Logger
. "$PSScriptRoot\get-logger.ps1"
$Logger = Get-Logger "$PSScriptRoot\Log.txt"

. "$PSScriptRoot\functions.location.ps1"
. "$PSScriptRoot\functions.ci.ps1"
. "$PSScriptRoot\functions.link.ps1"

[string]$DatabaseName = 'ParkPC'
[string]$SQLServerName = 'vsql2016.novator.ru'

[string]$connString = 'Server=' + $SQLServerName + ';Database=' + $DatabaseName + ';Persist Security Info=False;Integrated Security=SSPI'
[string]$SQLCommand = "SELECT [Num_Komp]
,[Schet]
,[Data]
,[Gde]
,[What]
,[Comp_bP]
,[Comp_bP_Text]
,[Doc]
,[Tex_Doc]
,[Other]
,[Other2]
,[Other3]
,[Other4]
,[Other5]
,[User_FIO]
,[User_Date]
,[Model_PC]
,[SpecProv]
,[Naznach]
FROM [ParkPC].[dbo].[Main] where User_Date >= DATEADD(DAY, -$Days, GETDATE()) and User_FIO is not NULL"

$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
	$conn.Open()

    $cmd = New-Object System.Data.SqlClient.SqlCommand($SQLCommand, $conn)
	$cmdR = $cmd.ExecuteReader()

    while ($cmdR.Read()) { 
        Write-Host ==============================================
        #====NK=====
        $NK = $cmdR['Num_Komp']
        Write-host "NK" $NK
       

        #====Naznach=====
        $Naznach = $cmdR['Naznach']; if ($Naznach -is [System.DBNull]){$Naznach = ""}
        switch ($Naznach) {
            {$Naznach.Contains("Inter")} {$Network = 'Internet'; Write-Host "Internet"}
            Default {$Network = 'Local'; Write-Host "Local"}
        }
        #====User_FIO=====
        $Owner=''
        Write-Host User_FIO = $cmdR['User_FIO']
        $User_FIO = $cmdR['User_FIO']; if ($User_FIO -is [System.DBNull]){$User_FIO = ""}
        switch ($cmdR['User_FIO']) {
            {$User_FIO.Contains("СПИСАН")} {$State = 'Списан'; Write-Host "Списан"}
            {$User_FIO.Contains("ПРОДАН")}{$State = 'Списан'; Write-Host "Списан"}
            {$User_FIO.Contains("ПЕРЕДАН")}{$State = 'Списан'; Write-Host "Списан"}
            {$User_FIO.Contains("СКЛАД")}{$State = 'Склад'; Write-Host "Склад"}
            Default {if ($User_FIO -ne "") {
                $Owner = (get-aduser -Filter "Name -like '*$User_FIO*'").samaccountname
                $State = 'В работе'
                Write-Host "Owner" $User_FIO $Owner
                }
            }
        }
        #====What=====
        Write-Host What = $cmdR['What']
        $What = $cmdR['What']; if ($What -is [System.DBNull]){$What = ""}
        switch ($What) {
            {$What.Contains("комплект")} {$Type ='Десктоп'; Write-Host "Десктоп"}
            {$What.Contains("ноутбук")}{$Type = 'Ноутбук'; Write-Host "Ноутбук"}
            {$What.Contains("ровербук")}{$Type = 'Ноутбук'; Write-Host "Ноутбук"}
            {$What.Contains("касса")}{$Type = 'Hardware'; Write-Host "Hardware"}
            {$What.Contains("моноблок")}{$Type = 'Моноблок'; Write-Host "Моноблок"}
            {$What.Contains("сервер")}{$Type = 'Сервер'; Write-Host "сервер"}
            {$What.Contains("система хранения")}{$Type = 'СХД'; Write-Host "СХД"}
            {$What.Contains("МФУ")}{$Type = 'Printer'; Write-Host "Printer"}
            {$What.Contains("Принтер")}{$Type = 'Printer'; Write-Host "Printer"}
            Default {$Type = 'Десктоп'; Write-Host "Десктоп"}
        }
        #====Model=====
        $Model = $cmdR['Model_PC']
        #====Description=====
        $Description = ("Счет: " + $cmdR['Schet'] + " Дата: " + $cmdR['Data']  + " : " + $cmdR['Doc']  + " : " + $cmdR['Tex_Doc'] + " : " + $cmdR['Other']).Replace('&','').Replace('<','')
        #====SpecProv=====
        #$Secure = $cmdR['SpecProv']
        $Secure = 'No'
        if ($Type -eq 'СХД')
        {   
            $id = search-id_forNK "Hardware" $NK
            if ($id -eq $null){
                Write-host "create KE"
            $configitem_id = create-hardware $NK 
            }
            else # update hardware
            {
                #обновлять нечего - не сохраняем в базе ничего
                #$configitem_id = create-hardware $NK 
            }
        }
        elseif ($Type -ne "Printer") 
        {
            $Incident = 'Исправен'
             #Проверяем существование компьютера
            $id = search-id_forNK "Computer" $NK
            Write-host "id" $id
            if ($id -eq $null){
                #создаем КЕ
                Write-host "create KE"
                $configitem_id = create-computer $NK $Owner $State $Incident $Network $Type $Description $Model $Secure            
                #====================================================================================================
                #   Link to locations
                #====================================================================================================
                $geo_id = search-location_id-for_NK $NK
                if ([string]::IsNullOrEmpty($geo_id) -eq $false)   {
                create-link ITSMConfigItem $configitem_id ITSMConfigItem $geo_id Includes
                Write-host "Cвязан с geo_id $geo_id"
                Write-host "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
            }
            }
            else # update computer
            {
                Write-host "update KE"
                $configitem_id = update-computer $id $NK $Owner $State $Incident $Network $Type $Description $Model $Secure            
            }   
        Write-Host ==============================================
        
        }

}
$cmdR.Close()
$conn.Close()
