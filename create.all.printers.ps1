# v1 Создаем принтеры и привязываем к пользователям
# Разовый запуск - первоначальное создание объектов
# Принтеры и Локации берем из C2

#Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
Get-Date | Write-Host 

#=====Logger
#. "$PSScriptRoot\get-logger.ps1"
#$Logger = Get-Logger "$PSScriptRoot\Log.txt"

. "$PSScriptRoot\functions.location.ps1"
. "$PSScriptRoot\functions.ci.ps1"
. "$PSScriptRoot\functions.link.ps1"


#====================================================================================================
#Create printers
#====================================================================================================

[int]$startNK = 0

[string]$DatabaseName = 'C2'
[string]$SQLServerName = 'vsql2016.novator.ru'

[string]$connString = 'Server=' + $SQLServerName + ';Database=' + $DatabaseName + ';Persist Security Info=False;Integrated Security=SSPI'
[string]$SQLCommand = "
SELECT [NK] as [Name],[Memo] as IPAddress, SUBSTRING(NK,5,4) as NK, 
    SUBSTRING(NK,10,len(NK)) as Model, MACs.MAC, MACs.Description FROM [C2].[dbo].[NKs] as NKs
    left join MACs
    on NKs.ID = MACs.ID_NK
    where [NK] like 'PRN [0-9]%'
"

$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
$conn.Open()

$cmd = New-Object System.Data.SqlClient.SqlCommand($SQLCommand, $conn)
$cmdR = $cmd.ExecuteReader()
while ($cmdR.Read()) { 
    Write-Host ==============================================
    #====NK=====
    $NK = $cmdR['NK']
    Write-host "NK" $NK
    $Name = $cmdR['Name']
    $IPAddress = $cmdR['IPAddress']
    $Model = $cmdR['Model']
    $MACAddress = $cmdR['MAC']
    $Description = $cmdR['Description']
    $State = 'В работе'
    $Incident = 'Исправен'
    $configitem_id = create-printer $NK $Name $State $Incident $Description $Model $IPAddress $MACAddress

            #====================================================================================================
            #   Link to locations
            #====================================================================================================
            $geo_id = search-location_id-for_PrinterName $Name
            if ([string]::IsNullOrEmpty($geo_id) -eq $false)   {
                #start-sleep -s 5
                create-link ITSMConfigItem $configitem_id ITSMConfigItem $geo_id Includes
                Write-host "Cвязан с geo_id $geo_id"
                Write-host "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
            }
            #Pause
            Write-host "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
}

