# v1 Синхронизируем принтеры и привязываем к локациям
# - Перебираем записи с максимальным NK в С2 и создаем принтеры которых нет в OTRS

Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

. "$PSScriptRoot\functions.printer.ps1"
. "$PSScriptRoot\functions.link.ps1"
. "$PSScriptRoot\functions.share.ps1"
. "$PSScriptRoot\Set-GlobalVars.ps1"

    Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
    $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

[string]$DatabaseName = 'C2'

[string]$connString = 'Server=' + $SQLServerName + ';Database=' + $DatabaseName + ';Persist Security Info=False;Integrated Security=SSPI'
[string]$SQLCommand = "
SELECT [NK] as [Name],[Memo] as IPAddress, SUBSTRING(NK,5,4) as NK, 
    SUBSTRING(NK,10,len(NK)) as Model, MACs.MAC, MACs.Description FROM [C2].[dbo].[NKs] as NKs
    left join MACs
    on NKs.ID = MACs.ID_NK
    where [NK] like 'PRN [0-9]%' order by NK DESC"

$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
$conn.Open()
$cmd = New-Object System.Data.SqlClient.SqlCommand($SQLCommand, $conn)
$cmdR = $cmd.ExecuteReader()
while ($cmdR.Read()) { 
    Write-Host ==============================================
    #====NK=====
    [int]$NK = $cmdR['NK']
    Write-host "NK" $NK
    $Name = $cmdR['Name']
    $IPAddress = $cmdR['IPAddress']
    $Model = $cmdR['Model']
    $MACAddress = $cmdR['MAC']
    $Description = $cmdR['Description']
    $State = 'В работе'
    $Incident = 'Исправен'

# Если принтер не существует в OTRS- создаем
$id = get-ConfigItemId "Printer" $NK
Write-Host ('id ' + $id)
if ([string]::IsNullOrEmpty($id)){
    $configitem_id = create-printer $NK $Name $State $Incident $Description $Model $IPAddress $MACAddress
    Write-Host ('Create printer ' + $NK)

            #====================================================================================================
            #   Link to locations
            #====================================================================================================
            $geo_id = get-C2LinkedLocationName $Name
            if ([string]::IsNullOrEmpty($geo_id) -eq $false)   {
                create-link ITSMConfigItem $configitem_id ITSMConfigItem $geo_id ConnectedTo Valid 4
                Write-host "Cвязан с geo_id $geo_id"
                Write-host "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
            }
}
else {
    Exit
}
}
