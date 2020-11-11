function sync-links {
<#
    .SYNOPSIS
    Sync SCS changes
    Синхронизируем выборку измененений в SCS из С2 за последний период
    SCS = DB, собираемая с активного сетевого оборудования.
    .DESCRIPTION
    For use this functions you have to create SOAP Webservice with named operation.
    Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
    .PARAMETER Days
    Period
    .LINK
   https://github/daniloveb/otrs_ps
    #>
    [CmdletBinding()]
    param (
    [Parameter( Mandatory = $true )] [int] $Days)

    Set-StrictMode -Version Latest
    $ErrorActionPreference='Stop'

    . "$PSScriptRoot\Set-GlobalVars.ps1"
    . "$PSScriptRoot\functions.link.ps1"
    . "$PSScriptRoot\functions.share.ps1"
    . "$PSScriptRoot\functions.c2.ps1"

    Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
    $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

    [string]$DatabaseName = 'C2'
    [string]$connString = 'Server=' + $SQLServerName + ';Database=' + $DatabaseName + ';Persist Security Info=False;Integrated Security=SSPI'
    [string]$SQLCommand = "
    Select [Name] from
    (SELECT [LogTime]
      ,[ColumnName]
      ,[OldValue]
      ,[NewValue]
  FROM [C2].[dbo].[Log] where LogTime >= DATEADD(DAY, -$Days, GETDATE()) and ColumnName = 'ID_vMACs') Logs
  left join 
  v_MACs_forLookup
  on NewValue = v_MACs_forLookup.Id
     where [Type] = 'NK'
  union
  Select [Name] from
  (SELECT [LogTime]
      ,[ColumnName]
      ,[OldValue]
      ,[NewValue]
  FROM [C2].[dbo].[Log] where LogTime >= DATEADD(DAY, -$Days, GETDATE()) and ColumnName = 'ID_vMACs') Logs
  left join 
  v_MACs_forLookup
   on OldValue = v_MACs_forLookup.Id
   where [Type] = 'NK'"

    $conn = New-Object System.Data.SqlClient.SqlConnection($connString)
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($SQLCommand, $conn)
    $cmdR = $cmd.ExecuteReader()
    #$PrinterName = ""
    while ($cmdR.Read()) { 
        $NK = $null
        #$PrinterName = $null
        Write-Host ==============================================
        $NameSQL = $cmdR['Name']
        $Name = $NameSQL.Substring(0,$NameSQL.Indexof(':'))
    Write-host Name $Name
    #Ищем связанную локация в с2
    $c2LinkedLocationName = get-C2LinkedLocationName $Name
    Write-host LocationName $c2LinkedLocationName
    #otrs id связанной локации
    $linkedLocationId = get-ConfigItemId Location $c2LinkedLocationName
    #otrs CI id
    if ($Name.Contains("PRN"))    {
        $CIID = get-ConfigItemId Printer $Name
    }
    else {
        [int]$NK = $Name
        $CIID = get-ConfigItemId Computer $NK
    }
    Write-Host CIID $CIID
    #if ($linkedLocationId -eq $null ){ break }
    #Выборка связанных локаций в otrs
    $Ids = link-list ITSMConfigItem $CIID ITSMConfigItem Valid 1
    Write-Host IDs $Ids
    #удаляем все связи с локациями кроме нужной
    if ($Ids -match $linkedLocationId){
        $Ids = $Ids | Where-Object {$_ -ne $linkedLocationId}
    }
    else {
        create-link ITSMConfigItem $CIID ITSMConfigItem $linkedLocationId ConnectedTo Valid 1
    }
    # Проверяем класс у ids
    #$IDs | Get-ConfigItem | ForEach-Object {$Class = $_.Class} | $ac += $_ #| If ($Class -eq 'Location'){ $Locs }
    foreach ($id in $Ids){
        if ((get-ConfigItem $id)['Class'] -eq 'Location'){
            Write-host (remove-link ITSMConfigItem $CIId ITSMConfigItem $id ConnectedTo 1)
        }
    }
}
}

#. "$PSScriptRoot\functions.location.ps1"
#. "$PSScriptRoot\functions.link.ps1"
#. "$PSScriptRoot\functions.share.ps1"
#synch-links 2